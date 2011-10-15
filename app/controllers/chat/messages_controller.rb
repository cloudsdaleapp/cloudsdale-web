class Chat::MessagesController < ApplicationController
  include ActionView::Helpers::AssetTagHelper
  def controller;self;end;private(:controller)
  
  def index
    @messages = Chat::Message.desc(:timestamp).limit(30)
    render json: @messages
  end
  
  def create
    @message = Chat::Message.new(sender: session[:display_name], content: params[:message], user_path: user_path(session[:user_id]))
    
    if @message.save
      render :partial => 'create.js.erb',
      :locals => {
                    :sender => @message.sender,
                    :content => @message.content.gsub(/\"/,'\\"'),
                    :timestamp => @message.timestamp.to_js,
                    :user_path => @message.user_path
                  }
    else
      render :json => @message.errors
    end
  end
  
end
