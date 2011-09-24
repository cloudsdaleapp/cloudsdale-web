class ApplicationController < ActionController::Base
  
  helper_method :current_user, :current_pony
  
  protect_from_forgery
  
  def authenticated?
    raise CanCan::AccessDenied.new unless current_user
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def current_pony
    @current_pony ||= current_user.primary_pony
  end
  
  def authenticate!(user)
    raise "No user to authenticate" if user.nil?
    raise "User has no Auth Token" if user.auth_token.nil?
    session[:user_id] = user.id
    session[:pony_id] = user.primary_pony
    @current_user = user
  end
  
end
