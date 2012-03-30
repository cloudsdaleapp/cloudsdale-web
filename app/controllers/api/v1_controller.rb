class Api::V1Controller < ActionController::Base
  
  before_filter :auth_token
  
  helper_method :current_user
  
  # Internal: Determains the current user by using
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
    if session[:user_id]
      @current_user ||= User.find_or_initialize_by(_id: session[:user_id])
    elsif @auth_token
      @current_user ||= User.find_or_initialize_by(auth_token: auth_token)
    else
      @current_user ||= User.new
    end
  end
  
  
  # Internal: Sets the auth token of the current request
  #
  # Returns the auth token.
  def auth_token
    @auth_token ||= request.headers['X-Auth-Token']
  end
  
end