class ChatController < ApplicationController
  
  def index
    session[:chat] = { :display_name => current_pony.name }
  end
  
end
