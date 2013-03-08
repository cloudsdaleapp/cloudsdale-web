class UsersController < ApplicationController

  # Private: Finds a user based on the token.
  # If a user is found, a session is set with that user,
  # removes the token, and saves the user with the;
  # "force_password_change" attribute set to true.
  #
  # token - The restoration token of a user
  #
  # Redirects you to the root page.
  def restore

    @user = User.where('restoration.token' => params[:token]).first
    authorize! :restore, @user

    if @user
      unless @user.restoration.expired?

        @user.email_verified_at = DateTime.now
        @user.force_password_change = true
        @user.password = nil
        @user.restoration = nil

        if @user.save
          session[:user_id] = @user.id
        end

        redirect_to root_path
      else
        redirect_to custom_error_path('token_error',title: 'Token Expired', sub_title: 'The token you are trying to access have expired.', status: 403)
      end

    else
      redirect_to custom_error_path('token_error',title: 'Token Error', sub_title: 'The token you have supplied is no longer valid. Try requesting a new one.', status: 500)
    end

  end

end
