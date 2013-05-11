class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController

  layout 'auth'

  helper_method :current_user

private

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
