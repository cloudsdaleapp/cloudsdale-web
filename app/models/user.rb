class User
  
  include Mongoid::Document
  include Mongo::Voter

  include Droppable
  
  embeds_one :character
  embeds_one :restoration
  embeds_one :checklist
  embeds_many :authentications
  embeds_many :notifications
  
  has_one :drop, as: :local_reference, dependent: :delete, autosave: true
  
  has_many :entries, as: :author
  has_many :owned_clouds, class_name: "Cloud", as: :owner
  
  has_and_belongs_to_many :clouds, :inverse_of => :users, dependent: :nullify
  has_and_belongs_to_many :subscribers, class_name: "User", :inverse_of => :publishers, dependent: :nullify
  has_and_belongs_to_many :publishers, class_name: "User", :inverse_of => :subscribers, dependent: :nullify
  
  
  field :email,                 type: String
  field :auth_token,            type: String
  field :password_hash,         type: String
  field :password_salt,         type: String
  field :time_zone,             type: String
  field :role,                  type: Integer,    default: 0
  field :member_since,          type: Time
  field :invisible,             type: Boolean,    default: false
  field :force_password_change, type: Boolean,    default: false
  
  field :subscribers_count,     type: Integer,    default: 0
  
  mount_uploader :avatar, AvatarUploader
  
  scope :top_subscribed, -> { order_by([:subscribers_count,:desc]) }
  scope :visable, where(:invisible => false)

  attr_accessible :email, :password, :password_confirmation, :auth_token, :authentications_attributes, :character_attributes, :avatar, :force_password_change, :time_zone
  attr_accessor :password
  
  accepts_nested_attributes_for :character, :allow_destroy => true
  accepts_nested_attributes_for :authentications, :allow_destroy => true
  
  validates_uniqueness_of :email
  validates :email, format: { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }
  validates :password, confirmation: true, length: { within: 6..56 }, :allow_blank => true
  validates :auth_token, uniqueness: true
  
  validates_exclusion_of :id, :in => lambda { |u| u.publisher_ids }, :message => "cannot subscribe to yourself"
  
  before_validation do
    self[:cloud_ids].uniq!
  end
  
  before_save do
    self[:auth_token]     = -> n { SecureRandom.hex(n) }.call(16) unless auth_token.present?
    self[:_type] = "User"
    self[:email] = self[:email].downcase if email.present?
    encrypt_password
    enable_account_on_password_change
    set_creation_date
    update_statistics
    remove_duplicate_subscriptions
    
    if drop.nil?
      self.build_drop
    end
    
    self.drop.url       = "#{Cloudsdale.config['url']}/users/#{self._id.to_s}"
    self.drop.match_id  = self.drop.url
    self.drop.title     = self.name
    self.drop.status    = ["200","OK"]
    self.drop.strategy  = :cloudsdale_users
    self.drop.hidden    = self.invisible.to_s
    self.drop.last_load = Time.now
  
    self.drop.src_meta ||= {}
  
    self.drop.src_meta['avatar']             = self.avatar.preview.url
    self.drop.src_meta['subscribers_count']  = self.subscribers_count
    self.drop.src_meta['member_since']       = self[:member_since] || Time.now
    self.drop.src_meta['reference_id']       = self._id.to_s
  end
  
  before_create do
    build_checklist
  end
  
  def to_indexed_json
    self.to_json(:only => [ :_id,:subscribers_count], :methods => [:name,:avatar_versions])
  end
  
  def avatar_versions
    { normal: avatar.url, mini: avatar.mini.url, thumb: avatar.thumb.url, preview: avatar.preview.url }
  end
  
  def self.authenticate(email, password)
    user = where(:email => email.downcase, :password_hash.exists => true, :password_salt.exists => true).first
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end
  
  def encrypt_password
    if password.present? == true
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
  
  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end
  
  def generate_auth_token
    self.auth_token = SecureRandom.hex(16) unless auth_token.present?
  end
  
  def set_creation_date
    unless member_since.present?
      self[:member_since] = Time.now
    end
  end
  
  def update_statistics
    self[:subscribers_count] = self.subscribers.count
  end
  
  def remove_duplicate_subscriptions
    self[:subscriber_ids].uniq!
    self[:publisher_ids].uniq!
  end
  
  def logout_and_save!
    save!
  end
  
  def enable_account_on_password_change
    if password_hash_changed?
      self[:force_password_change] = false if force_password_change?
    end
  end
  
  # Override to silently ignore trying to remove missing
  # previous avatar when destroying a User.
  def remove_avatar!
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
    end
  end

  # Override to silently ignore trying to remove missing
  # previous avatar when saving a new one.
  def remove_previously_stored_avatar
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
      @previous_model_for_avatar = nil
    end
  end
  
  def name
    self.character.name
  end
  
  def status_in_words
    is_online? ? 'online' : 'offline'
  end
  
end
