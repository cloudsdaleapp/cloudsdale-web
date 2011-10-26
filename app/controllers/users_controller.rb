class UsersController < ApplicationController
  
  def index
    @users = User.online.order([:last_activity,:desc]).limit(48)
  end
  
  def new
    @user = User.new
    @user.build_character
  end
  
  def edit
    @user = current_user
    authorize! :update, @user
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        authenticate!(@user)
        format.html { redirect_to root_path, :notice => 'Your account was successfully created, Welcome!.' }
      else
        format.html { render :action => :new, :errors => @user.errors }
      end
    end
  end
  
  def update
    @user = current_user
    @user.activities.build(category: :profile, text: 'Updated profile', url: user_path(@user))
    authorize! :update, @user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        session[:display_name] = @user.character.name
        format.js { render :json => { :flash => { :type => 'notice', :message => "Successfully updated user."} } }
        format.html { redirect_to edit_user_path(@user), :notice => "Successfully updated user." }
      else
        format.js { render :json => { :flash => { :type => 'error', :message => "Try again!" } } }
      end
    end
  end
  
  def restore
  end

end
