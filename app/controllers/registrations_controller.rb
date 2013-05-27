class RegistrationsController < ApplicationController

  layout 'auth',  only: [:new,:create]

  before_filter :redirect_if_registered!, only: [:new,:create]
  skip_before_filter :assert_user_ban!

  # Public: View for creating a new session.
  #
  # Renders the login page.
  def new
    @registration = Registration.new
  end

  # Public: View for verifying your registration
  #
  # Renders the verify page.
  def edit
    @registration = Registration.new
  end

  # Public: Endpoint for creating a session.
  #
  # Returns you to the stored path or returns you
  # to the site root if there is no stored path.
  def create
    @registration = Registration.new(permitted_params.registration.create)
    if @registration.valid?
      flash[:notice] = "Please check your inbox at #{@registration.email} for a verification email."
      edit_registe
    else
      render :new
    end
  end

  def update
  end

end
