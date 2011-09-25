class SessionsController < ApplicationController
  
  def create
    user = User.authenticate(params[:email], params[:password]) if params[:email] && params[:password]
    if user
      session[:user_id] = user.id
      redirect_to root_path, :notice => "Signed in in 10 seconds flat, maybe..."
    else
      flash[:error] = "Wrong email and password combination"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    session[:pony_id] = nil
    redirect_to root_path, :notice => "Bye!"
  end

end
