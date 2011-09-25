class Chat::MessagesController < ApplicationController
  
  def create
    sender = params[:sender]
    message = params[:message]
    channel = params[:channel]
    compiled_message = { :sender => sender, :message => message }
    chat_broadcast(channel,compiled_message)
    render :json => :success
  end
  
end