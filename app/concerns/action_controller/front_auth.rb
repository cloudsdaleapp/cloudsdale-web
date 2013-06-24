# encoding: utf-8
module ActionController::FrontAuth

  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  def current_user

    user_id    ||= session[:user_id]
    auth_token ||= cookies[:auth_token] || request.headers['X-Auth-Token']

    if user_id
      return @current_user ||= User.find_or_initialize_by(_id: session[:user_id])
    elsif auth_token
      return @current_user ||= User.find_or_initialize_by(auth_token: auth_token)
    else
      return @current_user ||= User.new
    end

  end

end
