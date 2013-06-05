class RegistrationsController < ApplicationController

  layout 'auth',  only: [:new,:create,:edit,:update]

  before_filter :redirect_if_registered!, only: [:new,:create]
  skip_before_filter :assert_user_ban!

  # Public: View for creating a new session.
  #
  # Renders the login page.
  def new
    session[:registration_token] = nil
    @registration = Registration.new
  end

  # Public: View for verifying your registration
  #
  # Renders the verify page.
  def edit
    if session[:registration_token].present?
      @registration = Registration.find(session[:registration_token])
    else
      flash[:error] = "You need to start a registration before you can verify it."
      redirect_to register_path
    end
  end

  # Public: Endpoint for creating a session.
  #
  # Returns you to the stored path or returns you
  # to the site root if there is no stored path.
  def create
    @registration = Registration.new(permitted_params.registration.create)

    if @registration.save
      session[:registration_token] = @registration.token
      send_verification_email_for @registration
      flash[:notice] = "Please check your inbox at #{@registration.email} for a verification email."
      redirect_to register_verification_path
    else
      render :new
    end
  end

  def update
    token = params[:token] || session[:registration_token]

    if token.present?

      @registration = Registration.find(token)

      if params[:commit].try(:parameterize) == "resend-code"
        send_verification_email_for(@registration)
        flash[:notice] = "Please check your inbox at #{@registration.email} for a verification email."
        render :edit
      else
        @registration.verify_token = params[:token] || params[:registration][:verify_token]

        if @registration.valid?
          @user = @registration.user

          timestamp = DateTime.current
          @user.email_verified_at         = timestamp
          @user.confirmed_registration_at = timestamp

          @registration.destroy
          session[:registration_token] = nil

          if @user.save
            authenticate! @user
            flash[:notice] = "Welcome to Cloudsdale, your registration has been verified."
            redirect_to root_path
          else
            flash[:error] = "We're really sorry, it seems has been a huge error. Please go through the proccess again."
            redirect_to register_path
          end

        else
          render :edit
        end

      end

    else
      flash[:error] = "You need to start a registration before you can verify it."
      redirect_to register_path
    end
  end

private

  def send_verification_email_for(registration)
    RegistrationMailer.delay(
      :queue => :high,
      :retry => true
    ).verification_mail(registration.token)
  end

end
