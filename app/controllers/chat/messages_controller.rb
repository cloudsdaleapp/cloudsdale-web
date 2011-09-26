class Chat::MessagesController < ApplicationController
  
  def create
    sender = session[:chat][:display_name]
    message = params[:message]
    channel = params[:channel]
    compiled_message = { :sender => sender, :message => message }
    chat_broadcast(channel,compiled_message)
    render :json => :success
  end
  
end