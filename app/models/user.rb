class User
  
  include Mongoid::Document
  include Mongo::Voter

  include Droppable
  
  attr_accessible :name, :email, :password, :invisible, :time_zone, :confirm_registration
  attr_accessor :password, :confirm_registration
  
  embeds_one :character
  embeds_one :restoration
  embeds_one :checklist
  embeds_many :authentications
  embeds_many :notifications
  
  has_many :owned_clouds, class_name: "Cloud", as: :owner
  
  has_and_belongs_to_many :clouds, :inverse_of => :users, dependent: :nullify
  
  field :name,                      type: String
  field :email,                     type: String
  field :auth_token,                type: String
  field :password_hash,             type: String
  field :password_salt,             type: String
  field :time_zone,                 type: String
  field :role,                      type: Integer,    default: 0
  field :member_since,              type: Time
  field :invisible,                 type: Boolean,    default: false
  field :force_password_change,     type: Boolean,    default: false
  field :force_name_change,         type: Boolean,    default: false
  field :tnc_last_accepted,         type: Date,       default: nil
  field :confirmed_registration_at, type: DateTime,   default: nil
    
  mount_uploader :avatar, AvatarUploader
  
  scope :visable, where(:invisible => false)
  
  accepts_nested_attributes_for :character, :allow_destroy => true
  accepts_nested_attributes_for :authentications, :allow_destroy => true
  
  validates :name,        length: { within: 2..20 }, format: { :with => /^[a-z0-9\_]*$/i }, allow_blank: true
  validates :email,       format: { with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }, uniqueness: true, allow_blank: true
  validates :password,    length: { within: 6..56 }, allow_blank: true
  validates :auth_token,  uniqueness: true, allow_blank: true
    
  before_validation do
    self[:cloud_ids].uniq!
  end
  
  before_save do
    self[:_type] = "User"
    self[:email] = self[:email].downcase if email.present?
    
    generate_auth_token
    encrypt_password
    enable_account_on_password_change
    set_confirmed_registration_date
    set_creation_date
  end
  
  # Public: Fetches the URL's for the avatar versions
  #
  # args - A hash of arguments of what to do with the avatar versions.
  #
  #   :except - Array of the version keys to be omitted from the hash
  # 
  #   :only   - An array of specific keys you want to include.
  #             will be overridden by any values from except.
  #
  # Examples
  #
  # @user.avatar_versions([:normal,:mini,:thumb,:preview])
  # # => { chat: "http://..." }
  #
  # Returns a hash of keys pointing at url values.
  def avatar_versions(args={})
    
    args = { except: [], only: nil }.merge(args)
    
    allowed_keys = [:normal,:thumb,:mini,:preview,:chat]
    
    allowed_keys.select! { |value| args[:only].include? value } if args[:only]
    allowed_keys -= args[:except]
    
    {
      normal: avatar.url,
      mini: avatar.mini.url,
      thumb: avatar.thumb.url,
      preview: avatar.preview.url,
      chat: avatar.chat.url
      
    }.delete_if do |key,value|
      
      !allowed_keys.include? key
      
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
    
    if oauth && oauth[:token] == INTERNAL_TOKEN
      
      if ["twitter","facebook"].include?(oauth[:provider])
        
        user = where('authentications.uid' => oauth[:uid], 'authentications.provider' => oauth[:provider]).first
        
      elsif "cloudsdale" == oauth[:provider]
        
        user = where(_id: oauth[:uid]).first
        
      end

    end
    
    if email && password && user.nil?
      
      user = where(
        :email => /#{email}/i,
        :password_hash.exists => true,
        :password_salt.exists => true
      ).first
      
      user = nil unless user && user.can_authenticate_with(password: password)
      
    end
    
    return user || User.new(email: options[:email], password: options[:password])
      
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
  
  # Internal: Generates an auth token unless an auth token is already set
  def generate_auth_token
    self[:auth_token] = -> n { SecureRandom.hex(n) }.call(16) unless auth_token.present?
  end
  
  # Internal: Sets the creation date of the User unless
  # a creation date is already set.
  def set_creation_date
    unless member_since.present?
      self[:member_since] = -> { Time.now }.call
    end
  end
  
  # Internal: Sets the :confirmed_registration_date if
  # :confirmed_registration is present and :confirmed_registration_at is nil
  # as well as having an email together with a valid registration method.
  def set_confirmed_registration_date
    if confirm_registration.present? && confirmed_registration_at.nil? && has_a_valid_authentication_method? && email.present?
      self[:confirmed_registration_at] = -> { DateTime.current }.call
    end
  end
  
  # Internal: Changes the state of force_password_change to true
  # if the password_hash has recently been changed.
  def enable_account_on_password_change
    if password_hash_changed?
      self[:force_password_change] = false if force_password_change?
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
    self[:force_password_change] || !self.password_hash.present? || !self.password_salt.present?
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
  def needs_name_change?
    self[:force_name_change] || !self.name.present?
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
  
  protected
  
  # Internal: Override to silently ignore trying to remove missing
  # previous avatar when destroying a User.
  def remove_avatar!
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
    end
  end

  # Internal: Override to silently ignore trying to remove missing
  # previous avatar when saving a new one.
  def remove_previously_stored_avatar
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
      @previous_model_for_avatar = nil
    end
  end
  
  private
  
  # Private: Encrypts the users password using a password salt & pepper
  #
  # Returns the password hash.
  def encrypt_password
    if password.present? == true
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
  
end
