class EmailsController < ApplicationController

  skip_before_filter  :redirect_on_maintenance!

  before_filter :authorize_email_token

  def unsubscribe
    @user.update_attribute(:email_subscriber,false)
    redirect_to root_path
  end

  def verify
    timestamp = DateTime.now
    @user.update_attribute(:email_verified_at,timestamp)
    redirect_to root_path
  end

private

  def authorize_email_token
    @user = User.find_by(email_token: params[:id])

    session[:user_id]    = @user.id.to_s
    cookies[:auth_token] = @user.auth_token
    @auth_token          = @user.auth_token
    @current_user        = @user

  rescue Mongoid::Errors::DocumentNotFound
    redirect_to root_path
  end

end
