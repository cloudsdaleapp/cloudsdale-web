class ChatController < ApplicationController
  
  def index
    session[:chat] = { :display_name => current_pony.name, :token => current_user.auth_token }
  end
  
  def connect
    render :partial => 'connect.js.erb'
  end
  
  def disconnect
    render :partial => 'disconnect.js.erb'
  end
  
  def presence
    render :partial => 'presence.js.erb'
  end
  
end
