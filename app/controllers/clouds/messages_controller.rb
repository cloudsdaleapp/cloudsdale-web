class Clouds::MessagesController < ApplicationController
  
  include ActionView::Helpers::AssetTagHelper
  def controller;self;end;private(:controller)
  
  before_filter do
    @cloud = Cloud.find(params[:cloud_id])
  end
  
  def index
    @messages = @cloud.chat.messages.order_by([:timestamp,:desc]).limit(50).reverse
    respond_to do |format|
      format.json { render json: @messages.to_json }
    end
  end
  
  def create
    # Das chat cleaner.
    
    @cloud.chat.messages.order_by(:timestamp,:desc).skip(50).each{|m|m.destroy}
    @message = @cloud.chat.messages.build author: current_user, content: params[:message]
    
    if @message.save
      faye_broadcast "/cloud/#{@cloud.id}/chat", { uid: @message.author_id ,content: @message.content, timestamp: @message.timestamp.utc, user_name: @message.user_name, user_path: @message.user_path, user_avatar: @message.user_avatar, client_id: params[:client_id] }
      render :json => :success
    else
      render :json => @message.errors
    end
  end
  
end
