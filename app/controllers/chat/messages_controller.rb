class Chat::MessagesController < ApplicationController
  include ActionView::Helpers::AssetTagHelper
  def controller;self;end;private(:controller)
  
  def index
    @messages = Chat::Message.limit(20)
    render json: @messages
  end
  
  def create
    sender = session[:display_name]
    message = params[:message]
    t = Time.now
    
    message.gsub! /<\/?[^>]*>/, ""
    
    if (m = message.match(/^(.*)/i))
      msg = m[0].gsub /([a-z]{1,6}\:\/\/)([a-z0-9\.\,\-\_]*)(\/?[a-z0-9\.\,\-\_\/\?\&\=]*)/i do
        protocol = $1
        top_dom = $2
        path = $3
        url = protocol + top_dom + path
        "<a class='chat-link' href='#{url}' target='_blank'>#{url}</a>"
      end
    end
    
    if Chat::Message.create(sender: sender, timestamp: t, content: msg)
      render :partial => 'create.js.erb',
      :locals => {
                    :sender => sender,
                    :message => msg.html_safe,
                    :timestamp => t.to_js
                  }
    end
  end
  
end
