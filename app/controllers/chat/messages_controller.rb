# encoding: UTF-8
class Chat::MessagesController < ApplicationController
  include ActionView::Helpers::AssetTagHelper
  def controller;self;end;private(:controller)
  
  def create
    sender = session[:chat][:display_name]
    message = params[:message]
    channel = params[:channel]
    t = Time.now
    
    message.gsub! /<\/?[^>]*>/, ""
    
    if (m = message.match(/^\/(\S*)\s?(.*)/i)) # Match all commands
      render :partial => 'command.js.erb', :locals => { :channel => channel, :message => "\"#{m[1]}\" - command not recognized", :timestamp => t.to_js, :humanized_timestamp => t.strftime('%R')}
    elsif (m = message.match(/^(.*)/i))
      msg = m[0].gsub /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_]*)(\/?[a-z0-9\.\,\-\_\/\?\&\=]*)/i do
        protocol = $1
        top_dom = $2
        path = $3
        url = protocol + top_dom + path
        
        if ($3 =~ /jpe?g|png|gif|bmp/i) != nil
          "<a class='chat-img-link' href='#{url}' target='_blank'>#{url}<img src='#{image_path("/assets/icons/image.png")}'></img></a>"
        else
          "<a class='chat-link' href='#{url}' target='_blank'>#{url}<img src='#{image_path("/assets/icons/link.png")}'></img></a>"
        end
      end
      render :partial => 'create.js.erb', :locals => { :channel => channel, :sender => sender, :message => msg.html_safe, :timestamp => t.to_js, :humanized_timestamp => t.strftime('%R')}
    end
    
  end
  
end