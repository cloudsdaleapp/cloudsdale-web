class SessionsController < ApplicationController
  
  layout 'front'
  
  skip_before_filter :redirect_on_maintenance!
  skip_before_filter :force_password_change!
  
  before_filter only: [:new] do
    if current_user
      redirect_to root_path
    end
  end
  
  def new
  end
  
  def create
    user = User.authenticate(params[:email], params[:password]) if params[:email] && params[:password]
    if user
      authenticate!(user)
      redirect_to unless_pending_request_go_to(root_path)
    else
      flash[:error] = "Login Failed! Wrong email and password combination, maybe you're not a member?"
      redirect_to login_path
    end
  end

  def destroy
    if request.env['HTTP_REFERER'].nil? or !request.env['HTTP_REFERER'].match(/^http:\/\/(local|www)\.cloudsdale.org/i).nil?
      current_user.logout_and_save! if current_user
      session[:user_id] = nil
      redirect_to login_path, notice: "Logged out successfully!"
    else
      flash[:error] = "Something went wrong and you could not terminate your session..."
      redirect_to root_path
    end
  end

end
