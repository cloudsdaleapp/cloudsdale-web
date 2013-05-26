class Registration

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  attr_accessor :display_name, :username, :email, :password
  attr_accessor :verification_code, :awaits_verification

  # Public: Initializes the model according to
  # regular active model convention.
  #
  # attributes - The model attributes
  #              :username     - The Username for the user.
  #              :password     - The Password for the user.
  #              :email        - The Email for user.
  #              :display_name - The display name for the user.
  #
  # Returns self for command chaining.
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    return self
  end

  # Public: Converts self to a set of parameters
  # which can be used to create a new user.
  def to_user_parameters
    user_params = Hash.new
    user_params.email         = self.email
    user_params.username      = self.username
    user_params.display_name  = self.display_name
    user_params.password      = self.password
    return user_params
  end

  # Public: Returns a new user based on own
  # user paramaters.
  def user
    @user ||= User.new(self.to_user_parameters)
  end

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
  }

  validates :verification_code,   presence: true,   :if => :awaits_verification

  def persisted?
    false
  end

end
