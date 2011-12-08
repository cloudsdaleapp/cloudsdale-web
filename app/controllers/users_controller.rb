class UsersController < ApplicationController
  
  skip_before_filter :force_password_change!, only: [:change_password, :update_password]
  
  def index
    if params[:tab].nil?
      @users = User.online.order([:last_activity,:desc]).limit(48)
    elsif params[:tab] == 'most_subscribed'
      @users = User.top_subscribed.limit(48)
    elsif params[:tab] == 'random'
      @users = User.limit(48).shuffle
    end
  end
  
  def new
    @user = User.new
    @user.build_character
    render :layout => 'front'
  end
  
  def edit
    @user = current_user
    authorize! :update, @user
  end
  
  def show
    @user = User.find(params[:id])
    authorize! :read, @user
    if params[:tab].nil?
    elsif params[:tab] == 'articles'
      @articles = @user.entries.order_by([:created_at,:desc]).page(params[:articles_page]).per(10)
    end
  end
  
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        authenticate!(@user)
        format.html { redirect_to root_path, :notice => notify_with(:success,'','Your account was successfully created, Welcome!.') }
      else
        format.html { render :action => :new }
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
        format.html { redirect_to edit_user_path(@user), :notice => notify_with(:success,'User',"successfully updated.") }
      else
        format.html { redirect_to edit_user_path(@user), :notice => notify_with(:error,'User',"cloud not be updated, try again.") }
      end
    end
  end
  
  def change_password
    @user = current_user
    authorize! :update, @user
    render layout: 'front'
  end
  
  def update_password
    @user = current_user
    authorize! :update, @user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to root_path, :notice => notify_with(:success,'Password',"successfully changed.") }
      else
        format.html { render change_password_user(@user), :notice => notify_with(:error,'Password',"cloud not be changed, try again.") }
      end
    end
  end

end
