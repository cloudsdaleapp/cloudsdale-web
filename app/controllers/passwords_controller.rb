class PasswordsController < ApplicationController

  layout 'auth'

  def new
    session[:password_reset_token] = nil
    @password_reset = PasswordReset.new
  end

  def show
    if session[:password_reset_token].present?
      @password_reset = PasswordReset.find(session[:password_reset_token])
    else
      flash[:error] = "You must start this proccess before you can verify."
      redirect_to password_reset_path
    end
  end

  def edit
    @password_reset = PasswordReset.find(params[:token])
  end

  def update
    @password_reset = PasswordReset.find(params[:token])
    @password_reset.needs_password!

    if @password_reset.update_attributes(permitted_params.password_reset.update)

      @user = @password_reset.user
      @user.password_hash = @password_reset.password_hash
      @user.password_salt = @password_reset.password_salt
      @user.force_password_change = false

      session[:password_reset_token] = nil
      @password_reset.destroy

      if authenticate!(@user)
        send_confirmation_mail(@user.id)
        flash[:success] = "Password has been changed successfully and you can now use Cloudsdale as usual. Have fun!"
        redirect_to root_path
      else
        flash[:error] = "We're sorry, something went horribly wrong. Please try and contact staff through ask@cloudsdale.org"
        redirect_to password_reset_path
      end

    else
      render :edit
    end
  end

  def verify
    token = params[:token] || session[:password_reset_token]

    if token.present?

      @password_reset = PasswordReset.find(token)
      @password_reset.needs_verification!

      if params[:commit].try(:parameterize) == "resend-code"
        send_reset_mail(@password_reset)

        flash[:notice] = "The password reset email has been sent to '#{@password_reset.identifier}'"
        render :show
      else
        @password_reset.verify_token = params[:token] || params[:password_reset][:verify_token]
        if @password_reset.save
          flash[:notice] = "Please change your password before you continue using Cloudsdale."
          redirect_to password_change_path(@password_reset.token)
        else
          render :show
        end
      end

    else
      flash[:error] = "You need to start the proccess before verifying your reset."
      redirect_to password_reset_path
    end

  end

  def create
    @password_reset = PasswordReset.new(permitted_params.password_reset.create)
    if @password_reset.save
      send_reset_mail(@password_reset)
      session[:password_reset_token] = @password_reset.token

      flash[:notice] = "The password reset email has been sent to '#{@password_reset.identifier}'"
      redirect_to password_verify_path
    else
      render :new
    end
  end

private

  def send_reset_mail(password_reset)
    PasswordResetMailer.delay(
      :queue => :high,
      :retry => true
    ).verification_mail(password_reset.token)
  end

  def send_confirmation_mail(user_id)
    PasswordResetMailer.delay(
      :queue => :high,
      :retry => true
    ).confirmation_mail(user_id)
  end

end
