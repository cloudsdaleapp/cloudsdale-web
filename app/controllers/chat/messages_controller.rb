class Chat::MessagesController < ApplicationController
  
  def create
    sender = session[:chat][:display_name]
    message = params[:message]
    channel = params[:channel]
    t = Time.now
    
    message.gsub! /(<[^>]*>)|\n|\t/s, ""
    
    compiled_message = { :sender => sender, :message => message, :timestamp => t.to_js, :humanized_timestamp => t.strftime('%R')}
    chat_broadcast(channel,compiled_message)
    render :json => :success
  end
  
end