class User < ActiveRecord::Base
  
  attr_accessible :email, :password, :password_confirmation, :auth_token, :authentications_attributes
  attr_accessor :password
  
  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications, :allow_destroy => true
  
  
  validates :email, uniqueness: true, format: { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }
  validates :password, :confirmation => true, :on => :create
  validates :auth_token, :presence => true
  
  before_save :encrypt_password
  before_validation :generate_auth_token
  
  def self.authenticate(email, password)
    user = find_by_email(email)
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
    self.email = omniauth['user_info']['email'] if email.blank?
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end
  
  def generate_auth_token
    self.auth_token = SecureRandom.hex(16) unless auth_token.present?
  end
  
end
