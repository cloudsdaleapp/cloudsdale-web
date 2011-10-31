class Chat::Rooms::MessagesController < ApplicationController
  
  include ActionView::Helpers::AssetTagHelper
  def controller;self;end;private(:controller)
  
  before_filter do
    @room = Chat::Room.find(params[:room_id])
  end
  
  def index
    @messages = @room.messages.order_by([:timestamp,:desc]).limit(50).reverse
    respond_to do |format|
      format.json { render json: @messages.to_json }
    end
  end
  
  def create
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
