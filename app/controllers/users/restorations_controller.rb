class Users::RestorationsController < ApplicationController
  
  skip_before_filter :force_password_change!
  
  layout 'front'
  
  def show
    @user = User.find(params[:user_id])
    respond_to do |format|
      if @user != nil and params[:id] == @user.restoration.try(:token) and !@user.restoration.try(:expired?)
        authenticate!(@user)
        @user.update_attributes(force_password_change: true)
        @user.restoration.destroy
        format.html { redirect_to root_path }
      else
        flash[:error] = "Error! restoration process is invalid or has expired."
        format.html { redirect_to login_path }
      end
    end
  end
  
  def create
    @user = User.where(email: params[:email].downcase).first
    if @user
      @user.create_restoration
      UserMailer.restore_mail(@user).deliver
    end
    respond_to do |format|
      format.html { redirect_to login_path, notice: "#{params[:email]} has received an email." }
    end
  end
  
end