class SessionsController < ApplicationController

  skip_before_filter :assert_user_ban!

  # Public: Terminates the session for the current user.
  #
  # Returns you to the root page.
  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

end
