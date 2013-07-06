# encoding: utf-8
module ActionController::FrontAuth

  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :auth_token
  end

  # Public: Determines the current user by using
  # sessions falling back on x-auth-token request header
  # initializing a new user if none of these are present.
  #
  # Examples
  #
  # current_user
  # #=> #<User ...>
  #
  # Returns an inatance of the User model.
  def current_user
    if auth_token
      @current_user ||= User.find_or_initialize_by(auth_token: auth_token)
    else
      @current_user ||= User.new
    end
  end

  # Protected: Sets the auth token of the current request
  #
  # Returns the auth token.
  def auth_token
    @auth_token ||= cookies.signed[:auth_token] || request.headers['X-Auth-Token']
  end

end
