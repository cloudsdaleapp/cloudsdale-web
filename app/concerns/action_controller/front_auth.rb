# encoding: utf-8
module ActionController::FrontAuth

  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :auth_token, :current_resource_owner
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
      @current_user ||= guest_user
    end
  end

  # Public: User helper for API using oAuth access tokens.
  # Falls back on using session data if request is AJAX,
  # or no access token exists.
  #
  # Returns a user object or nil.
  def current_resource_owner
    super if defined? super
    if doorkeeper_token
      @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id)
    else
      @current_resource_owner ||= current_user
    end
  end

  # Protected: Sets the auth token of the current request
  #
  # Returns the auth token.
  def auth_token
    @auth_token ||= cookies.signed[:auth_token] || request.headers['X-Auth-Token']
  end

  # Public: The guest user is a user object generated from
  # a pre-generated BSON::ObjectID, stored in the session hash.
  # This is to reduce the amount of bandwidth that goes through
  # the CDN because of dynamic avatar generation based on user id.
  #
  # Returns a user record.
  def guest_user
    @guest_user ||= User.new do |user|
      user.id = session[:guest_user_id] if session[:guest_user_id].present?
    end
    session[:guest_user_id] = @guest_user.id
    return @guest_user
  end

end
