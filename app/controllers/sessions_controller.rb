class SessionsController < ApplicationController
  
  layout 'front'
  
  before_filter only: [:new] do
    if current_user
      redirect_to root_path
    end
  end
  
  def new
  end
  
  def index
    @users = User.online
    render partial: 'index', :locales => { user: @user }
  end
  
  def create
    user = User.authenticate(params[:email], params[:password]) if params[:email] && params[:password]
    if user
      authenticate!(user)
      redirect_to root_path, :notice => notify_with(:success,"Signed in!","in 10 seconds flat...")
    else
      flash[:notice] = notify_with :error, "Error:", "wrong email and password combination"
      render :new
    end
  end

  def destroy
    current_user.logout_and_save!
    session[:user_id] = nil
    redirect_to root_path
  end

end
