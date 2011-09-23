class User < ActiveRecord::Base
  
  attr_accessible :email, :password, :password_confirmation, :auth_token, :authentications_attributes, :ponies_attributes
  attr_accessor :password
  
  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications, :allow_destroy => true
  
  has_many :ponies
  accepts_nested_attributes_for :ponies
  
  validates_uniqueness_of :email
  validates :email, format: { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }
  validates :password, confirmation: true
  validates :auth_token, presence: true
  
  
  before_validation :generate_auth_token
  before_save do
    encrypt_password
    self[:pony_id] = ponies.first.id unless ponies.empty? && pony_id != nil
  end
  
  def self.authenticate(email, password)
    user = where("password_salt IS NOT NULL and password_hash IS NOT NULL and email = ?",email).first
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
  
  def primary_pony
    ponies.find(self[:pony_id]) if self[:pony_id]
  end
  
end
