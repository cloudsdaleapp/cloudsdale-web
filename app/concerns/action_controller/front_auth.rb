# encoding: utf-8
module ActionController::FrontAuth

  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :auth_token
  end

  def current_user
    if auth_token
      @current_user ||= User.find_or_initialize_by(auth_token: auth_token)
    else
      @current_user ||= User.new
    end
  end

  def auth_token
    @auth_token ||= cookies.signed[:auth_token] || request.headers['X-Auth-Token']
  end

end
