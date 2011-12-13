class Chat::Rooms::MessagesController < ApplicationController
  
  include ActionView::Helpers::AssetTagHelper
  def controller;self;end;private(:controller)
  
  before_filter do
    @cloud = Cloud.where('chat._id' => BSON::ObjectId(params[:room_id])).first
    @room = @cloud.chat
  end
  
  def index
    @messages = @room.messages.order_by([:timestamp,:asc]).limit(50)
    respond_to do |format|
      format.json { render json: @messages.to_json(:methods => :formatted_timestamp) }
    end
  end
  
  def create
    # Das chat cleaner.
    @room.messages.order_by(:timestamp,:desc).skip(50).each{|m|m.destroy}
    
    @message = @room.messages.build(
      author: current_user,
      content: params[:message]
    )
      
    if @message.save
      faye_broadcast "/chat/room/#{@room.id}", { author: @message.author, content: @message.content, timestamp: @message.timestamp, formatted_timestamp: @message.formatted_timestamp, user_name: @message.user_name, user_path: @message.user_path, user_avatar: @message.user_avatar }
      render :json => :success
    else
      render :json => @message.errors
    end
  end
  
end
