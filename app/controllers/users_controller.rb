class UsersController < ApplicationController
  
  def new
    @user = User.new
    @user.ponies.build
  end
  
  def edit
    @user = User.find(params[:id])
    authorize! :update, @user
    respond_to do |format|
      format.html { render :partial => 'edit', locals: { :user => @user } }
    end
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
  
  def update
    @user = User.find(params[:id])
    authorize! :update, @user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { render :json => { :flash => { :type => 'notice', :message => "Successfully updated user."} } }
      else
        format.html { render :json => { :flash => { :type => 'error', :message => "Try again!" } } }
      end
    end
  end
  
  def restore
  end

end
