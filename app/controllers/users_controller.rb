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

    if @user

      if @user.restoration.expired?

        @user.restoration = nil
        @user.save

      else

        @user.email_verified_at = DateTime.now
        @user.force_password_change = true
        @user.password = nil
        @user.restoration = nil

        session[:user_id] = @user.id if @user.save

      end

    end

    redirect_to root_path
  end

end
