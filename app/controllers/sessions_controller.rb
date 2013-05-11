class SessionsController < ApplicationController

  layout 'auth',  only: [:new,:create]

  before_filter :redirect_if_registered!, only: [:new,:create]
  skip_before_filter :assert_user_ban!

  # Public: View for creating a new session.
  #
  # Renders the login page.
  def new
    @session = Session.new
  end

  # Public: Endpoint for creating a session.
  #
  # Returns you to the stored path or returns you
  # to the site root if there is no stored path.
  def create
    @session = Session.new(permitted_params.session.create)
    if @session.valid?
      authenticate! @session.user
      redirect_to_stored_url
    else
      render :new
    end
  end

  # Public: Terminates the session for the current user,
  # as well as auth token saved in cookies.
  #
  # Returns him to the root path with a flash message.
  def destroy
    flash[:notice]    = "You have successfully logged out."

    session[:user_id] = nil
    cookies.delete(:auth_token)

    redirect_to root_path
  end

end
