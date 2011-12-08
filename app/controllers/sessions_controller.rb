class SessionsController < ApplicationController
  
  layout 'front'
  
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
    current_user.logout_and_save!
    session[:user_id] = nil
    redirect_to root_path
  end

end
