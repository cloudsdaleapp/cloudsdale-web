class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  helper_method :current_user
  
  before_filter :redirect_on_maintenance!
  before_filter :set_time_zone_for_user!
  
  around_filter  :render_root_page!
  
  # Rescues the error yielded from not finding requested document
  rescue_from Mongoid::Errors::DocumentNotFound do |message|
    render not_found_path, status: 404
  end
  
  # Rescues the error from not being authorized to perform an action
  rescue_from CanCan::AccessDenied do |message|
    render unauthorized_path, status: 401
  end
  
  # Rescues the errors yielded by supplying a faulty BSON id
  rescue_from BSON::InvalidObjectId do |message|
    render server_error_path, status: 500
  end
    
  def current_user
    if session[:user_id]
      @current_user ||= User.find_or_initialize_by(_id: session[:user_id])
    else
      @current_user ||= User.new
    end
  end
  
  private
  
  # Public: Takes rails errors and 
  def errors_to_string(errors)
    str = ""
    errors.each { |k,v| str += "#{k.to_s.gsub(/[\.\_\-]/i,' ')}: #{v}" }
    flash[:error] = str
  end
  
  protected
  
  # Internal: Forces users that are not of role moderator or higher to get redirected to
  # the maintenence page. The site will still work as normal even though maintenance
  # mode is activated for the users with sufficient rights.
  #
  # Returns nothing of intrest.
  def redirect_on_maintenance!
    if MAINTENANCE
      unless current_user and current_user.role >= 2
        redirect_to maintenance_path
      end
    end
  end
  
  def set_time_zone_for_user!
    Time.zone = current_user.time_zone if current_user and current_user.time_zone
  end
  
  # Internal: This is called after each method call on controllers
  # inheriting from this (ApplicationController)
  def render_root_page!
    render 'root/index', status: 500
  end
  
end
