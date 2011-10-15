class User
  
  include Mongoid::Document
  
  embeds_one :character
  embeds_many :authentications
  
  field :email,           type: String
  field :auth_token,      type: String
  field :password_hash,   type: String
  field :password_salt,   type: String
  
  field :member_since,    type: Time
  field :last_activity,   type: Time
  field :invisible,       type: Boolean, :default => false
  
  scope :online, -> { where(:last_activity.gt => 5.minutes.ago) }
  scope :public, where(:invisible => false)

  attr_accessible :email, :password, :password_confirmation, :auth_token, :authentications_attributes, :character_attributes
  attr_accessor :password
  
  accepts_nested_attributes_for :character, :allow_destroy => true
  accepts_nested_attributes_for :authentications, :allow_destroy => true
  
  validates_uniqueness_of :email
  validates :email, format: { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }
  validates :password, confirmation: true
  validates :auth_token, presence: true, uniqueness: true
  
  before_validation :generate_auth_token
  
  before_save do
    encrypt_password
    set_creation_date
  end
  
  def online
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
  
  def log_activity_and_save!
    self[:last_activity] = Time.now
    save!
  end

  
end
