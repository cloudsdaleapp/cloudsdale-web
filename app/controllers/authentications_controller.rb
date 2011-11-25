class AuthenticationsController < ApplicationController
  
  def create
    omniauth = request.env["omniauth.auth"]
    found_user = User.where("authentications.provider" => omniauth['provider'], "authentications.uid" => omniauth['uid']).first
    respond_to do |format|
      if found_user
        authenticate!(found_user)
        format.html { redirect_to unless_pending_request_go_to(root_path),
                      :notice => notify_with(:success,"Signed in successfully","using #{omniauth['provider'].capitalize}") }
      elsif current_user
        current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
        format.html { redirect_to unless_pending_request_go_to(:back),
                      :notice => notify_with(:success,"#{omniauth['provider'].capitalize}","authentication, successfully added.") }
      else
        @user = User.new
        @user.build_character
        @user.apply_omniauth(omniauth)
        format.html { render_and_act_as :users, :new, 'front' }
      end
    end
  end
  
  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = notify_with(:success,"#{@authentication.provider.capitalize}","authentication, successfully disconnected from your account.")
    redirect_to :back
  end
  
end
