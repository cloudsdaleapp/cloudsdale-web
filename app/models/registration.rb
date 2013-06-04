class Registration

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token

  attr_accessor :password, :verify_token

  after_save :schedule_for_expiration

  field :display_name
  field :username
  field :email
  field :password_salt
  field :password_hash

  token length: 5,  contains: :fixed_numeric

  validates :email,         presence: true,   email: true

  validates :username,      presence: true,   username: true, length: {
    maximum: 20,
    minimum: 1,
    too_long: "must not be longer than 20 characters.",
    too_short: "must contain characters."
  }

  validates :display_name,  presence: true

  validates :password,      presence: true,   length: {
    minimum: 6,
    too_short: "must be at least 6 characters"
  }, format: {
    with: /^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$/,
    message: "must contain both letters and numbers"
  }, :if => :new_record?

  validates :verify_token,  presence: true,   matches_field: {
      field: :token,
      message: "does not match the registration code"
  }, :unless => :new_record?

  # Public: Custom setter for the password
  # attribute. Converting it to a password
  # hash and a password salt for security
  # measures.
  #
  # Returns the password string.
  def password=(val)
    if val.present?
      self.password_salt = BCrypt::Engine.generate_salt unless password_salt.present?
      self.password_hash = BCrypt::Engine.hash_secret(val, password_salt)
    end
    @password = val
  end

  # Public: Converts self to a set of parameters
  # which can be used to create a new user.
  def to_user
    @user               = User.new
    @user.email         = self.email
    @user.username      = self.username
    @user.name          = self.display_name
    @user.password_salt = self.password_salt
    @user.password_hash = self.password_hash
    return @user
  end

  # Public: Returns a new user based on own
  # user paramaters.
  def user
    @user ||= self.to_user
  end

  def persisted?
    false
  end

private

  def schedule_for_expiration
    RegistrationExpirationWorker.perform_in(48.hours,self.id.to_s)
  end

end
