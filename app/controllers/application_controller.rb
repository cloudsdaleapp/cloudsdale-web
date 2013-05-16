class ApplicationController < ActionController::Base

  include Pundit

  helper_method :current_user

  before_filter :auth_token
  before_filter :redirect_on_maintenance!, :set_time_zone_for_user!, :assert_user_ban!

  rescue_from Mongoid::Errors::DocumentNotFound do |message|
    render 'exceptions/not_found', status: 404
  end

  rescue_from ActionController::RoutingError do |message|
    render 'exceptions/not_found', status: 404
  end

  # Rescues the error from not being authorized to perform an action
  rescue_from Pundit::NotAuthorizedError do |message|
    flash[:error] = "Unauthorized access! #{message}"
    render 'exceptions/unauthorized', status: 403
  end

  # Rescues the errors yielded by supplying a faulty BSON id
  rescue_from Moped::Errors::InvalidObjectId do |message|
    render 'exceptions/server_error', status: 500
  end

  rescue_from ActionController::ParameterMissing do |message|
    flash[:error] = "Invalid parameters, please try again."
    render 'exceptions/unproccessable_entry', status: 422
  end

  def current_user

    if session[:user_id]
      @current_user ||= User.find_or_initialize_by(_id: session[:user_id])
    elsif auth_token
      @current_user ||= User.find_or_initialize_by(auth_token: auth_token)
    else
      @current_user ||= User.new
    end

  end

  # Public: Takes rails errors and ....
  def errors_to_string(errors)
    str = ""
    errors.each { |k,v| str += "#{k.to_s.gsub(/[\.\_\-]/i,' ')}: #{v}" }
    flash[:error] = str
  end

protected

  # Internal: Forces users that are not of role moderator or
  # higher to get redirected to the maintenence page. The site
  # will still work as normal even though maintenance mode is
  # activated for the users with sufficient rights.
  #
  # Returns nothing of intrest.
  def redirect_on_maintenance!
    if MAINTENANCE
      unless current_user and current_user.role >= 2
        redirect_to maintenance_path
      end
    end
  end

  # Internal: Redirects user to the root path if he or she
  # is already registered. This is most likely to be used on
  # on authentication endpoints to make sure an authenticated
  # user does not authenticate twice.
  #
  # Returns nothing of interest.
  def redirect_if_registered!
    unless current_user.new_record?
      flash[:error] = "You are already logged in, please log out if you want to use another account."
      redirect_to root_path
    end
  end

  def set_time_zone_for_user!
    Time.zone = current_user.time_zone if current_user and current_user.time_zone
  end

  def assert_user_ban!
    if current_user.banned?
      redirect_to logout_path
    end
  end

  def auth_token
    @auth_token ||= cookies[:auth_token] || request.headers['X-Auth-Token']
  end

  def permitted_params
    PermittedParams.new(params,current_user)
  end

  def redirect_url
    @redirect_url ||= session[:redirect_url] || params[:redirect_url] || root_path
  end

  def redirect_to_stored_url
    url = redirect_url
    session[:redirect_url] = nil
    redirect_to url
  end

private

  # Private: Used to set a session for the user if the persist_session parameter is available.
  # It will also save the user to the database to ensure any new SHIT added to the user model
  # is persisted.
  def authenticate!(user)
    session[:user_id]    = user.id.to_s
    cookies[:auth_token] = auth_token
    @auth_token          = auth_token
    @current_user        = user
    user.save
  end

end
