class User
  
  include Mongoid::Document
  
  embeds_one :character
  embeds_many :authentications
  embeds_many :activities
  embeds_many :notifications
  
  has_many :articles, as: :author
  
  has_and_belongs_to_many :subscribers, class_name: "User", :inverse_of => :publishers, dependent: :nullify
  has_and_belongs_to_many :publishers, class_name: "User", :inverse_of => :subscribers, dependent: :nullify
  has_and_belongs_to_many :rooms, class_name: "Chat::Room", :inverse_of => :users, dependent: :nullify
  
  field :email,           type: String
  field :auth_token,      type: String
  field :password_hash,   type: String
  field :password_salt,   type: String
  field :role,            type: Integer,    default: 0
  field :member_since,    type: Time
  field :last_activity,   type: Time
  field :invisible,       type: Boolean,    default: false
  
  field :subscribers_count,    type: Integer,    default: 0
  
  mount_uploader :avatar, AvatarUploader
  
  scope :online, -> { where(:last_activity.gt => 10.minutes.ago) }
  scope :top_subscribed, -> { order_by([:subscribers_count,:desc]) }
  scope :visable, where(:invisible => false)

  attr_accessible :email, :password, :password_confirmation, :auth_token, :authentications_attributes, :character_attributes, :avatar
  attr_accessor :password
  
  accepts_nested_attributes_for :character, :allow_destroy => true
  accepts_nested_attributes_for :authentications, :allow_destroy => true
  
  validates_uniqueness_of :email
  validates :email, format: { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }
  validates :password, confirmation: true
  validates :auth_token, presence: true, uniqueness: true
  
  validates_exclusion_of :id, :in => lambda { |u| u.publisher_ids }, :message => "cannot subscribe to yourself"
  
  before_validation :generate_auth_token
  
  before_save do
    encrypt_password
    set_creation_date
    update_statistics
  end

  
  before_create do
    self[:last_activity] = Time.now
  end
  
  def is_online?
    self.last_activity > 10.minutes.ago
  end
  
  def self.authenticate(email, password)
    user = where(:email => email, :password_hash.exists => true, :password_salt.exists => true).first
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
    email = omniauth['user_info']['email'] if email.blank?
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
  
  def log_activity_and_save!
    self[:last_activity] = Time.now
    save!
  end
  
  def logout_and_save!
    self[:last_activity] = Time.now - 10.minutes
    save!
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
