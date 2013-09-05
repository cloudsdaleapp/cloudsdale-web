class User

  ROLES    = { normal: 0, donor: 1, legacy: 2, associate: 3, verified: 4, admin: 5, developer: 6, founder: 7 }
  STATUSES = { offline: 0, online: 1, away: 2, busy: 3 }

  include AMQPConnector

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::FullTextSearch
  include Mongoid::Identifiable
  include User::Emailable
  include User::Named
  include ActiveModel::Avatars

  include Droppable

  attr_accessible :password, :invisible, :time_zone, :confirm_registration, :avatar
  attr_accessible :remote_avatar_url, :remove_avatar, :skype_name, :preferred_status
  attr_accessor :password, :confirm_registration, :status

  embeds_one  :restoration,     :validate => false
  embeds_many :authentications, :validate => false

  has_many :conversations, :validate => false,  class_name: "Conversation", dependent: :destroy, inverse_of: :user
  has_many :references,    :validate => false,  class_name: "Conversation", dependent: :destroy, inverse_of: :topic

  has_many :owned_clouds, class_name: "Cloud", as: :owner, :validate => false

  has_and_belongs_to_many :clouds,            :inverse_of => :users,      dependent: :nullify,  index: true, :validate => false
  has_and_belongs_to_many :clouds_moderated,  :inverse_of => :moderators, dependent: :nullify,  class_name: "Cloud",  index: true, :validate => false

  identity :username

  # User Input Data
  field :preferred_status,          type: Symbol,     default: :online
  field :skype_name,                type: String
  field :time_zone,                 type: String

  # Authentication Data
  field :auth_token,                type: String
  field :password_hash,             type: String
  field :password_salt,             type: String
  field :force_password_change,     type: Boolean,    default: false

  # Statistics
  field :conversation_count,        type: Integer,    default: 0
  field :dates_seen,                type: Array,      default: []

  # Events
  field :tnc_last_accepted,         type: Date,       default: nil
  field :confirmed_registration_at, type: DateTime,   default: nil
  field :suspended_until,           type: DateTime,   default: nil
  field :reason_for_suspension,     type: String,     default: nil

  # Flags
  field :role,                      type: Integer,    default: 0
  field :developer,                 type: Boolean,    default: false
  field :invisible,                 type: Boolean,    default: false

  index( { _id: 1 }, { unique: true, name: 'id_index'} )
  index( { auth_token: 1 }, { unique: true, name: 'auth_token_index' } )

  scope :developers, self.or(:developer => true).or(:role.gte => ROLES[:developer])

  scope :visable, where(:invisible => false)

  scope :online_on, -> _cloud do
    ids = []
    user_statuses = Cloudsdale.redisClient.hgetall("cloudsdale/clouds/#{_cloud.id.to_s}/users")
    user_statuses.each { |uid,t| t = t.try(:to_i) || 0; min = 35.seconds.ago.to_ms; ids << uid if t > min }
    where(:_id.in => ids, :preferred_status.ne => :offline)
  end

  scope :available_for_mass_email, where(:email.ne => nil).only(:id)

  fulltext_search_in :search_string, :filters => {
    invisible: lambda { |user| user.invisible? },
    visible:   lambda { |user| not user.invisible? }
  }

  accepts_nested_attributes_for :authentications, :allow_destroy => true

  validates :auth_token,  uniqueness: true

  validates_length_of :password,  minimum: 6, :too_short => "pick a longer password, at least 6 characters", if: :password
  validates_presence_of :password, :if => :confirm_registration

  validate :forced_password_change, if: :force_password_change_changed?

  before_validation do
    self[:cloud_ids].uniq! if self[:cloud_ids]
    self[:clouds_moderated_ids].uniq! if self[:clouds_moderated_ids]
  end

  after_initialize do
    self[:_type] = "User"
  end

  before_save do
    add_known_name

    generate_auth_token  unless auth_token.present?

    set_confirmed_registration_date
  end

  after_save do

    enqueue! "faye", { channel: "/users/#{self._id.to_s}", data: self.to_hash }
    enqueue! "faye", { channel: "/users/#{self._id.to_s}/private", data: self.to_hash( template: "api/v1/users/private" ) }

    if name_changed? or preferred_status_changed? or role_changed? or avatar_changed? or username_changed? or avatar_purged
      self.cloud_ids.each { |cloud_id| enqueue!("faye", { channel: "/clouds/#{cloud_id.to_s}/users/#{self._id.to_s}", data: self.to_hash( template: "api/v1/users/mini") }) }
    end

    if email_changed? && email.present? && !confirmed_registration_at_changed? && !email_verified_at.present? && !new_record?
      UserMailer.delay(:queue => :high, :retry => false).verification_mail(self.id.to_s)
    end

  end

  # Public: Atomic setter for when the user was last seen in action
  #
  # Returns the timestamp
  def seen!
    timestamp = DateTime.now

    datestamp = timestamp.to_date.to_s
    unless self.dates_seen.include?(datestamp)
      self.push(:dates_seen, datestamp)
    end

    return timestamp
  end

  def password=(val=nil)
    if val.present? && (@password != val)

      self.force_password_change = false if self.force_password_change

      self.password_salt = BCrypt::Engine.generate_salt unless password_salt.present?
      self.password_hash = BCrypt::Engine.hash_secret(val, password_salt)

      @password = val

    end
  end

  # Public: Fetches the users status
  #
  # Returns the user status as a symbol, can be:
  # :online, :offline, :away or :busy
  def status
    return @status if @status.present?
    status_timestamp = Cloudsdale.redisClient.get("cloudsdale/users/#{self.id.to_s}").try(:to_i) || 0
    minimum_time_threshold = 35.seconds.ago.to_ms
    if status_timestamp > minimum_time_threshold
      return @status = self.preferred_status || :online
    else
      return @status = :offline
    end
  end

  # Public: Translates the User object to a HASH string using RABL
  #
  #   args - A Hash of arguments to be sent to the rabl, renderer.
  #
  # Examples
  #
  # @user.to_hash
  # # => { name: "..." }
  #
  # Returns a Hash.
  def to_hash(args={})
    defaults = { template: "api/v1/users/base", view_path: "#{Rails.root}/app/views" }
    options = defaults.merge(args)

    Rabl.render(self, options[:template], :view_path => options[:view_path], :format => 'hash')
  end

  # Public: Gets the symbolic name of the users role.
  #
  # Returns a Symbol, eg. :normal, :donor, :legacy, :associate, :admin, :developer, :verified, :founder
  def symbolic_role
    ROLES.invert[self[:role]]
  end

  # Public: Use a symbol to check if the user is of a specific role.
  #
  #   sym - The symbolic version of a role.
  #         Defaults to :normal, :donor, :legacy, :associate, :admin, :developer, :verified, :founder
  #
  # Returns true of the user is can act as one of these roles otherwise false.
  def is_of_role?(sym=:normal)
    ROLES[sym] ? (self[:role] >= ROLES[sym]) : false
  end

  # Public: Lists the active bans for a user
  #
  # Returns an array of the bans.
  def bans
    bans ||= []
    self.clouds.map do |cloud|
      cloud.bans.active.on_user(self).each { |ban| bans.push(ban) }
    end
    return bans.uniq
  end

  # Public: An Alias for the ´ban´ method with a bang to also save
  # the user record to the database.
  #
  #   date_time - The DateTime of when the suspension will seize.
  #
  # Returns true if the user could be saved.
  def ban!(date_time=nil, reason="unknown reason")
    date_time = DateTime.now + 48.hours unless date_time.present?
    ban(date_time,reason); save
  end

  # Public: Used to suspend a user for a set amount of time.
  #
  #   date_time - The DateTime of when the suspension will seize.
  #
  # Returns the DateTime instance.
  def ban(date_time=nil, reason="unknown reason")
    date_time = DateTime.now + 48.hours unless date_time.present?
    date_time = [DateTime,Time,Date].include?(date_time.class) ? date_time.to_datetime : DateTime.parse(date_time)
    self.suspended_until = date_time
    self.reason_for_suspension = reason
  end

  # Public: Instantly removes a suspension from a user.
  #
  # Returns nil.
  def unban; self.suspended_until = nil; end

  # Public: An Alias for the ´unban´ method with a bang to also save
  # the user record to the database.
  #
  # Returns true if the user could be saved.
  def unban!; unban; save; end

  # Public: Determines if the user is banned or not by comparing
  # the current DateTime to the value of :suspended_until field.
  #
  # Returns true if the user is banned otherwise false.
  def banned?
    if self.suspended_until
      self.suspended_until > -> { DateTime.now }.call
    else
      false
    end
  end

  # Public: Takes authentication options and tries to
  # resolve and return a user record.
  #
  # options - A options Hash which defaults to ({}):
  #
  #           :email - The registered email for a user
  #           :password - The password associated with that user
  #
  #           :oauth - A hash of oauth options defaults to nil:
  #
  #             :provider - String with the service oAuth provider
  #                         Can either be "facebook", "twitter" or "cloudsdale"
  #
  #             :uid -      String with the user id with the provider
  #
  #             :token -    String with the secret token for the user to allow the
  #                         application to access and authenticate.
  #
  #             :cli_type - String with the type of the client.
  #                         Currently supports "ios" or "android"
  #
  # Examples
  #
  # User.authenticate(oauth: { provider: 'facebook', uid: '1234...', token: '***', cli_type: 'iphone' } )
  # # => #<User:...>
  #
  # User.authenticate(password: '***', email: 'info@cl...')
  # # => #<User:...>
  #
  # Returns a user record.
  def self.authenticate(options={})

    email     = options[:email]
    password  = options[:password]
    oauth     = options[:oauth]
    user      = nil

    if oauth && oauth[:token] == BCrypt::Engine.hash_secret("#{oauth[:uid]}#{oauth[:provider]}",INTERNAL_TOKEN)

      if ["twitter","facebook"].include?(oauth[:provider])

        user = where('authentications.uid' => oauth[:uid], 'authentications.provider' => oauth[:provider]).first

      elsif "cloudsdale" == oauth[:provider]

        user = where(_id: oauth[:uid]).first

      end

    end

    if email && password && user.nil?

      session = Session.new(identifier: email, password: password)
      user    = session.user if session.valid?

    end

    if user.nil?

      if oauth && email && ["twitter","facebook"].include?(oauth[:provider])
        user = User.where(email: /^#{email}$/i).first || User.new(email: email)
        user.authentications.build(
          uid:      oauth[:uid],
          provider: oauth[:provider],
          token:    oauth[:auth_token],
          secret:   oauth[:auth_secret]
        )
      else
        user = User.new(email: email, password: password)
      end

    else

      if oauth && ["twitter","facebook"].include?(oauth[:provider])
        auth = user.authentications.find_or_initialize_by(provider: oauth[:provider], uid: oauth[:uid])
        auth.token  = oauth[:auth_token]  if oauth[:auth_token]
        auth.secret = oauth[:auth_secret] if oauth[:auth_secret]
      end

    end

    return user

  end

  # Public: Checks if the user can be authenticated
  # with the supplied parameters.
  #
  # options - A Hash containing the parameters to try and authenticate with
  #             :passsword - A String set by the user at registration
  #
  # Returns a Boolean that is true if the user could be authenticated
  def can_authenticate_with(options={})
    if options[:password].present? && self.password_hash.present? && self.password_salt.present?
      self.password_hash == BCrypt::Engine.hash_secret(options[:password], self.password_salt)
    else
      false
    end
  end

  # Public: Builds an authentication based upon omniauth metadata.
  #
  # omniauth - A hash provided by the omniauth gem.
  #
  # Returns an authentication instance.
  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  # Public: Generates a new auth token and invalidates the old one,
  # this might have some reprocussions if you're not careful.
  def generate_auth_token
    self[:auth_token] = SecureRandom.hex(16)
  end

  # Internal: Sets the :confirmed_registration_date if
  # :confirmed_registration is present and :confirmed_registration_at is nil
  # as well as having an email together with a valid registration method.
  def set_confirmed_registration_date
    if confirm_registration.present? && confirmed_registration_at.nil? && has_a_valid_authentication_method? && email.present?
      self[:confirmed_registration_at] = -> { DateTime.current }.call
    end
  end

  # Public: Determines wether the user has to change it's password
  # depending on if the :force_password_change attribute is true
  # or if :password_hash and :password_salt is not present.
  #
  # Examples
  #
  # @user.force_password_change
  # # => true
  #
  # Returns true or false depending on if the users has
  # to change it's password.
  def needs_password_change?
    self.force_password_change || (!self.password_hash.present? || !self.password_salt.present?)
  end

  # Public: Determines wether the user has to change it's username
  # depending on if the :force_username_change attribute is true
  # or the username is not set.
  #
  # Examples
  #
  # @user.force_username_change?
  # # => true
  #
  # Returns true or false depending on if the users has
  # to change it's username.
  def needs_username_change?
    self.force_username_change? || !self.username.present?
  end

  # Public: Determines wether the user has completed it's
  # registration or not based on the value of :confirmed_registration
  #
  # Examples
  #
  # @user.needs_to_confirm_registration?
  # # => true
  #
  # Returns true if :confirmed_registration_at is set otherwise false.
  def needs_to_confirm_registration?
    self[:confirmed_registration_at].nil?
  end

  # Public: Determines if the user has any form of viable authentication
  # methods present. eg. Twitter/Facebook or password authentications.
  #
  # Returns a Boolean being true if at least one authentication method is available.
  def has_a_valid_authentication_method?
    authentications.size > 0 || (self.password_hash.present? && self.password_salt.present?)
  end

  # Public: Determines if the user has completed the registration process.
  # depending on if the users email and a vaild authentication method is present.
  #
  # Examples
  #
  # @user.is_registered?
  # # => false
  #
  # Returns a Boolean, true if the user is registered otherwise false
  def is_registered?
    email.present? && has_a_valid_authentication_method?
  end

  # Private: Validation for when password is changed while forced password
  # equates to true.
  #
  # Returns false if validation fails
  def forced_password_change
    if force_password_change_was == true
      if password_hash_was == BCrypt::Engine.hash_secret(@password,password_salt)
        errors.add(:password, "cannot be the same")
        return false
      end
    end
  end

private

  # Private: The string which will be used to index a user.
  #
  # Returns the display name and the username of a user.
  def search_string
    [name, username].join(' ')
  end

end
