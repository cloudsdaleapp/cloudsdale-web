class Cloud

  include AMQPConnector
  include Jurisdiction

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::FullTextSearch

  include Droppable

  # Concerns
  include ActiveModel::Avatars

  embeds_one  :chat,  as: :topic,        :validate => false
  embeds_many :bans,  as: :jurisdiction, :validate => false

  attr_accessor :user_invite_tokens

  attr_accessible :name, :description, :short_name, :hidden, :locked,
                  :remove_avatar, :avatar, :remote_avatar_url, :rules,
                  :x_moderator_ids

  field :name,          type: String
  field :description,   type: String
  field :short_name,    type: String
  field :rules,         type: String
  field :hidden,        type: Boolean,        default: true
  field :locked,        type: Boolean,        default: false
  field :featured,      type: Boolean,        default: false
  field :member_count,  type: Integer,        default: 0
  field :drop_count,    type: Integer,        default: 0

  def x_moderator_ids=(mod_ids)
    mod_ids = mod_ids.map { |mod_id| mod_id.is_a?(Moped::BSON::ObjectId) ? mod_id : Moped::BSON::ObjectId(mod_id) }
    mod_ids = mod_ids.reject { |mod_id| !self[:user_ids].include?(mod_id) }
    self.moderators = User.where(:_id.in => mod_ids.uniq )
  end

  def short_name=(_short_name)
    if _short_name.present? && !self.short_name.present?
      self[:short_name] = _short_name.to_s.parameterize
    end
  end

  validates :name, presence: true, uniqueness: true, length: { within: 3..64 }
  validates :description, length: { maximum: 140 }
  validates :short_name, length: { maximum: 20, minimum: 5 }

  validates_uniqueness_of :short_name, :case_sensitive => true, if: :short_name?, message: "used by another cloud"
  validates_format_of :short_name,  with: /^[a-z0-9\_\-]*$/i, message: "must be alphanumeric, underscore and dashes only", if: :name?

  belongs_to :owner, polymorphic: true, index: true, :validate => false

  has_and_belongs_to_many :users,       :inverse_of => :clouds,             dependent: :nullify,  index: true,  :validate => false
  has_and_belongs_to_many :moderators,  :inverse_of => :clouds_moderated,   dependent: :nullify,  class_name: "User",   index: true,  :validate => false

  default_scope -> { without("chat.messages") }

  scope :popular, order_by(:member_count => :desc, :updated_at => :desc)
  scope :recent, order_by([:created_at, :desc])
  scope :visible, where(hidden: false)
  scope :hidden, where(hidden: true)
  scope :available_to, -> user {
    queryable.or(
      :"bans.offender_id".ne => user.id,
    ).or(
      :"bans.offender_id" => user.id,
      :"bans.due".lt => DateTime.current,
      :"bans.revoke" => false
    ).or(
      :"bans.offender_id" => user.id,
      :"bans.revoke" => true
    )
  }
  scope :unavailable_to, -> user {
    where(
      :"bans.due".gt => DateTime.current,
      :"bans.revoke" => false
    )
  }

  fulltext_search_in :search_string, :filters => {
    :public => lambda { |cloud| cloud.hidden == false },
    :hidden => lambda { |cloud| cloud.hidden == true }
  }

  after_initialize do
    self[:_type] = "Cloud"
  end

  before_validation do

    # Sets a new Owner from among the moderators if owner id is nil.
    self.owner = moderators.first if owner_id.nil? && !moderators.empty?

    # Sets a new Owner from among the users if owner id is nil.
    self.owner = users.first if owner_id.nil? && !users.empty?

    # Sets the owner to the user with the highest rank if owner_id is not present.
    self.owner = User.order_by([:role,:desc]).first if owner.nil?

    # Adds owner_id to moderator_ids if moderator_ids does not include the owner id.
    self.moderators << owner unless moderators.include?(owner)

     # Adds owner_id to user_ids if user_ids does not include the owner id.
    self.users << owner unless users.include?(owner)

    # Adds a moderator id to user_ids if user_ids does not include the moderator id.
    self.moderators.each do |moderator|
      self.users << moderator unless users.include?(moderator)
    end

    self[:name] = self[:name].slice(0..63) if name
    self[:user_ids].uniq!
    self[:moderator_ids].uniq!
  end

  before_save do

    self[:member_count] = self.user_ids.count

    build_chat unless chat.present?

  end

  after_save do
    _attributes = essential_attributes + (self.changed - ["user_ids"])

    enqueue! "faye", { channel: "/clouds/#{self._id.to_s}", data: self.to_hash(only: _attributes) }
  end

  # Public: Find record matching either ID or short name.
  # renders a Mongoid::Errors::DocumentNotFound if no cloud
  # is present.
  #
  # Examples
  #
  # Cloud.agnostic_fetch("short-name")
  # => <Cloud ...>
  #
  # Cloud.agnostic_fetch(BSON::ObjectId.new)
  # => <Cloud ...>
  #
  # Returns a Cloud record.
  def self.agnostic_fetch(id_or_short_name)
    cloud = where(
      "$or" => [{id: id_or_short_name}, {short_name: id_or_short_name}]
    ).first
    raise Mongoid::Errors::DocumentNotFound if cloud.nil?
    return cloud
  end

  # Public: List all online users for this Cloud.
  #
  # Examples
  #
  # @cloud.online_users
  # => <Mongoid::Criteria>
  #
  # Returns mongoid criteria for User.
  def online_users
    User.online_on(self)
  end

  # Public: Translates the Cloud object to a HASH string using RABL
  #
  #   args - A Hash of arguments to be sent to the rabl, renderer.
  #
  # Examples
  #
  # @cloud.to_hash
  # # => { name: "..." }
  #
  # Returns a Hash.
  def to_hash(args={})
    defaults = { template: "api/v1/clouds/base", view_path: 'app/views', only: [] }
    options = defaults.merge(args)

    _hash = Rabl.render(self, options[:template], :view_path => options[:view_path], :format => 'hash')
    _hash = _hash.select { |k,_| options[:only].include? k.to_s } if options[:only].present?

    return _hash
  end

  # Public: Determines which role a user has on an instance of a Cloud.
  #
  #   user - An instance of User.
  #
  # Returns a Symbol.
  def get_role_for(user)
    if user.id == self.owner_id
      return :owner
    elsif self.user_ids.include?(user.id)
      return :member
    else
      return :observer
    end
  end

  # Internal: The string which will be used to index a cloud.
  #
  # Returns the name and the description of the Cloud.
  def search_string
    [name, description].join(' ')
  end

  # Public: Fetch the 2 most recent drops for a Cloud that includes a preview image
  #
  # Returns a collection of Drop
  def recent_drops_with_preview
    Drop.after_on_topic(Time.now,self).only_visable.order_by_topic(self).with_preview_image.limit(2)
  end

private

  # Private: Attributes essential to clients
  #
  # Returns an Array with those attribute names
  def essential_attributes
    ["is_transient","id"]
  end

end
