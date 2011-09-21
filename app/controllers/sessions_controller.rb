class SessionsController < ApplicationController
  
  def create
    session[:user_id] = @user.auth_token
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

end
