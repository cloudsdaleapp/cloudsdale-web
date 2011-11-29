class Chat::Rooms::MessagesController < ApplicationController
  
  include ActionView::Helpers::AssetTagHelper
  def controller;self;end;private(:controller)
  
  before_filter do
    @cloud = Cloud.where('chat._id' => BSON::ObjectId(params[:room_id])).first
    @room = @cloud.chat
  end
  
  def index
    @messages = @room.messages.order_by([:timestamp,:desc]).limit(50).reverse
    respond_to do |format|
      format.json { render json: @messages.to_json }
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
      faye_broadcast "/chat/room/#{@room.id}", @message
      render :json => :success
    else
      render :json => @message.errors
    end
  end
  
end
