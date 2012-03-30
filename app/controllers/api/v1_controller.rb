class Api::V1Controller < ActionController::Base
  
  layout :determine_layout
  
  before_filter :auth_token
  
  helper_method :current_user
  
  # Rescues the error yielded from not finding requested document
  rescue_from Mongoid::Errors::DocumentNotFound do |message|
    render_exception "#{message} You sure this was what you were looking for?", 404
  end
  
  # Rescues the error from not being authorized to perform an action
  rescue_from CanCan::AccessDenied do |message|
    render_exception "You're not allowed to do this, GTFO. #{message}", 401
  end
  
  # Rescues the errors yielded by supplying a faulty BSON id
  rescue_from BSON::InvalidObjectId do |message|
    render_exception "BSON #{message}", 500
  end
  
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
  
  # Internal: Determines which layout to use based on the
  # requested content type.
  #
  # Examples
  #
  # class SomeController < SomeOtherController
  # 
  # layout :determine_layout
  #
  # end
  #
  # Returns a string with the layout name
  def determine_layout
    case request.format
    when /xml/
      'api_v1.xml'
    else
      'api_v1.json'
    end
  end
  
  # Public: Renders an exception back to the caller with a message and a status code.
  #
  # Examples
  #
  # render_exception "Not found", 404
  #
  # Returns a pretty render.
  def render_exception(error_message, status_code=500)
    @error = error_message
    render 'api/v1/exceptions/exception', status: status_code
  end
  
end