class UsersController < ApplicationController
  
  skip_before_filter :force_password_change!, only: [:change_password, :update_password]
  
  before_filter only: [:show,:edit,:update] do
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
    @user.build_character
    render :layout => 'front'
  end
  
  def edit
    authorize! :update, @user
  end
  
  def show
    authorize! :read, @user
    
    case params[:sort]
    when 'top_rated'
      sort = ['votes.point',:desc]
    when 'most_viwed'
      sort = [:total_views,:desc]
    else
      sort = ["deposits.#{@user.id}_updated_at", :desc]
    end
    
    @drops = Drop.only_visable.where("deposits.depositable_id" => @user.id).order_by(sort).page(params[:page] || 1).per(10)
    respond_to do |format|
      format.html {  }
      format.js { render partial: 'drops/list_content', locals: { depositable: @user } }
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
