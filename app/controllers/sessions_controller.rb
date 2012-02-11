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
      redirect_to unless_pending_request_go_to(root_path), :notice => notify_with(:success,"Signed in!","in 10 seconds flat...")
    else
      redirect_to '/login', :notice => notify_with(:error, "Error:", "wrong email and password combination")
    end
  end

  def destroy
    if request.env['HTTP_REFERER'].nil? or !request.env['HTTP_REFERER'].match(/^http:\/\/(local|www)\.cloudsdale.org/i).nil?
      current_user.logout_and_save! if current_user
      session[:user_id] = nil
      redirect_to login_path
    else
      redirect_to root_path
    end
  end

end
