class ApplicationController < ActionController::Base
  
  helper_method :current_user
  
  before_filter do
    begin
      current_user.log_activity_and_save! if current_user
    rescue
      session[:user_id] = nil
    end
  end
  
  protect_from_forgery
  
  def authenticated?
    raise CanCan::AccessDenied.new unless current_user
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def authenticate!(user)
    raise "No user to authenticate" if user.nil?
    session[:user_id] = user.id
    session[:display_name] = user.character.name
    @current_user = user
  end
  
end
