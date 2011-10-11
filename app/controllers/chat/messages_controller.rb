class Chat::MessagesController < ApplicationController
  include ActionView::Helpers::AssetTagHelper
  def controller;self;end;private(:controller)
  
  def index
    @messages = Chat::Message.desc(:timestamp).limit(30)
    render json: @messages
  end
  
  def create
    sender = session[:display_name]
    message = params[:message]
    t = Time.now
    
    message.gsub! /<\/?[^>]*>/, ""
    message.gsub! /[\u000d\u0009\u000c\u0085\u2028\u2029\n]/, "<br/>"
    message.gsub! /<br\/><br\/>/,"<br/>"
    message.gsub! /^\s*$/, ""
    
    if (m = message.match(/^(.*)/i))
      msg = m[0].gsub /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_]*)(\/?[a-z0-9\.\,\-\_\/\?\&\=]*)/i do
        protocol = $1
        top_dom = $2
        path = $3
        url = protocol + top_dom + path
        "<a class='chat-link' href='#{url}' target='_blank'>#{url}</a>"
      end
    end
    
    
    if Chat::Message.create(sender: sender, timestamp: t, content: msg) and !msg.empty?
      render :partial => 'create.js.erb',
      :locals => {
                    :sender => sender,
                    :message => msg,
                    :timestamp => t.to_js
                  }
    end
  end
  
end
