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
      redirect_to root_path, :notice => "Signed in in 10 seconds flat, maybe..."
    else
      flash[:error] = "Wrong email and password combination"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, :notice => "Bye!"
  end

end
