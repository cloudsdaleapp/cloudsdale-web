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
    
    @cloud.chat.messages.order_by(:timestamp,:desc).skip(50).each{|m|m.destroy}
    @message = @cloud.chat.messages.build author: current_user, content: params[:message], client_id: params[:client_id]
    
    @message.urls.each do |url|
      @cloud.create_drop_deposit_from_url_by_user(url,current_user)
    end
    
    if @message.save
      render :json => :success, status: 200
    else
      render :json => @message.errors
    end
    
  end
  
end
