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
    @current_pony ||= Pony.find(session[:pony_id]) if session[:pony_id]
  end
  
  def authenticate!(user)
    raise "No user to authenticate" if user.nil?
    raise "User has no Auth Token" if user.auth_token.nil?
    session[:user_id] = user.id
    if user.primary_pony.nil?
      user.pony_id = user.ponies.first.id
      user.save
    end
    session[:pony_id] = user.primary_pony unless user.primary_pony.nil?
    @current_user = user
  end
  
  def chat_broadcast(channel,data)
    message = { :channel => "/#{channel}", :data => data }
    Net::HTTP.post_form(Cloudsdale.faye_path, :message => message.to_json )
  end
  
end
