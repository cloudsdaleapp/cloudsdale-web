class Session

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  attr_accessor :identifier, :password, :user

  # Public: Initializes the model according to
  # regular active model convention.
  #
  # attributes - The model attributes
  #              :identifier - The Username or Email for session user
  #              :password   - The password for the session user
  #
  # Returns self for command chaining.
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    return self
  end

  def user
    if self.identifier.present?
      @user ||= Handle.lookup!(identifier.strip, kind: User)
      @user ||= User.where(email: identifier.downcase.strip).limit(1).first
    else
      @user ||= nil
    end
  end

  validates :user, password_combination: true
  validates :identifier, presence: true
  validates :password,   presence: true

  def persisted?
    false
  end

end
