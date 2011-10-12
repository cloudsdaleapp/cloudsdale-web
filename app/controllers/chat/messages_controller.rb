class Chat::MessagesController < ApplicationController
  include ActionView::Helpers::AssetTagHelper
  def controller;self;end;private(:controller)
  
  def index
    @messages = Chat::Message.desc(:timestamp).limit(30)
    render json: @messages
  end
  
  def create
    @message = Chat::Message.new(sender: session[:display_name], content: params[:message])
    
    if @message.save
      render :partial => 'create.js.erb',
      :locals => {
                    :sender => @message.sender,
                    :content => @message.content,
                    :timestamp => @message.timestamp.to_js
                  }
    else
      render :json => @message.errors
    end
  end
  
end
