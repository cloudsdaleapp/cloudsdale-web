class AuthenticationsController < ApplicationController
  
  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    
    respond_to do |format|
      if authentication
        authenticate!(authentication.user)
        format.html { redirect_to root_path,
                      :notice => "Signed in successfully using #{authentication.provider.capitalize}" }
      elsif current_user
        current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
        format.html { redirect_to root_path,
                      :notice => "#{omniauth['provider'].capitalize} authentication, successfully added." }
      else
        @user = User.new
        @user.apply_omniauth(omniauth)
        format.html { render "users/new" }
      end
    end
  end
end
