class Api::V1Controller < ActionController::Base
  
  layout :determine_layout
  
  before_filter :auth_token
  after_filter :build_response_headers
  
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
  
  # Internal: Determines if the client doing the API call is an
  # authorized client - This means the client has access to inhouse
  # methods in the API.
  #
  # Examples
  #
  # INTERNAL_TOKEN
  # # => "1234"
  #
  # request.env['X_AUTH_INTERNAL_TOKEN']
  # # => "1234"
  #
  # authorized_client?
  # # => true
  #
  # Returns a TrueClass or FalseClass depending on the state on the client of the current request.
  def authorized_client?
    request.env['X_AUTH_INTERNAL_TOKEN'] == INTERNAL_TOKEN
  end
  
  # Internal: Determines the current user by using
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
  
  
  # Public: Sets the auth token of the current request
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
  
  # Public: helper method to help determine how many records
  # to fetch when fetching a collection based on the "limit"
  # parameter sent by the client. If a negative value is supplied
  # or if the limit parameter is nil, the method will return
  # the fallback_limit which is 1 by default.
  #
  # fallback - Integer of which limit to use if no limit parameter is supplied.
  # max - Integer of the maximum amount of records that are allowed to be fetched.
  #
  # Examples
  #
  # params[:limit] = 50
  #
  # User.all.limit record_limit(5,100)
  # # => 50
  #
  # User.all.limit record_limit(5,30)
  # # => 30
  #
  #
  # params[:limit] = -1
  #
  # User.all.limit record_limit(5)
  # # => 5
  #
  # Returns an integer.
  def record_limit(fallback=0,max=nil)
    i = params[:limit].try(:to_i) || fallback
    i = i > max ? max : i if max
    i > 0 ? i : fallback
  end
  
  # Builds some generic response headers, among them
  # X-Auth-Token // If a current user is present
  #
  # Examples
  #
  # after_filter :build_response_headers
  # 
  # Returns "ok".
  def build_response_headers
    response.headers['X-Auth-Token'] = current_user.auth_token unless current_user.new_record?
    "ok"
  end
  
end