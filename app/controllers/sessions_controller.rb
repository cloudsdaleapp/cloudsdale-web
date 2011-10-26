class SessionsController < ApplicationController
  
  def index
    @users = User.online
    render partial: 'index', :locales => { user: @user }
  end
  
  def count
    respond_to do |format|
      format.json { render json: User.online.count }
      format.js { render json: User.online.count }
    end
  end
  
  def create
    user = User.authenticate(params[:email], params[:password]) if params[:email] && params[:password]
    if user
      authenticate!(user)
      redirect_to root_path, :notice => notify_with(:success,"Signed in!","in 10 seconds flat...")
    else
      flash[:error] = "Wrong email and password combination"
      render :new
    end
  end

  def destroy
    current_user.logout_and_save!
    session[:user_id] = nil
    redirect_to root_path, :notice => notify_with(:success,"Signed out!","see ya later...")
  end

end
