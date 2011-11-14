class ApplicationController < ActionController::Base
  
  helper_method :current_user
  
  before_filter do
    begin
      current_user.log_activity! if current_user
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
  
  def notify_with(cat=:success,title="Sucessful",msg="")
    { "category" => cat.to_s, "title" => title, "message" => msg }
  end
  
  def faye_broadcast(channel, data)
    message = { :channel => channel, :data => data }
    Net::HTTP.post_form(Cloudsdale.faye_path, :message => message.to_json)
  end
  
end
