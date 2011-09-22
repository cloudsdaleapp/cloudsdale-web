class ApplicationController < ActionController::Base
  
  helper_method :current_user
  
  protect_from_forgery
  
  def authenticated?
    raise CanCan::AccessDenied.new unless current_user
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def authenticate!(user)
    raise "No user to authenticate" if user.nil?
    raise "User has no Auth Token" if user.auth_token.nil?
    session[:user_id] = user.id
    @current_user = user
  end
  
end
