class PasswordReset

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token

  attr_accessor :password, :verify_token

  after_create :schedule_for_expiration

  token length: 5,  contains: :fixed_numeric

  field :identifier,      type: String
  field :password_hash,   type: String
  field :password_salt,   type: String

  validates :identifier,    presence: true

  validates :password,  presence: true,   length: {
    minimum: 6,
    too_short: "must be at least 6 characters"
  }, format: {
    with: /^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$/,
    message: "must contain both letters and numbers"
  }, :if => :needs_password?

  validates :verify_token,  presence: true,   matches_field: {
      field: :token,
      message: "does not match the password reset code"
  }, :if => :needs_verification?

  validates :user,  proxied_presence: {
    output: :identifier,
    message: "no user found using this identifier"
  }

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

  # Public: Custom setter for the identifier
  # attribute, which will fetch the corresponding
  # user if present.
  def user
    @user ||= User.or(username: /^#{self.identifier}$/i)
      .or(email: /^#{self.identifier}$/i)
      .first
  end

  def needs_verification?
    @needs_verification == true
  end

  def needs_verification!
    @needs_verification = true
  end

  def needs_password?
    @needs_password == true
  end

  def needs_password!
    @needs_password = true
  end

private

  def schedule_for_expiration
    RecordExpirationWorker.perform_in(48.hours, *[self.class.to_s, self.id.to_s])
  end

end
