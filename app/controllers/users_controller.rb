class UsersController < ApplicationController
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        authenticate!(@user)
        format.html { redirect_to root_path, :notice => 'Successfully created your account.' }
      else
        format.html { render :action => :new, :errors => @user.errors }
      end
    end
  end

end
