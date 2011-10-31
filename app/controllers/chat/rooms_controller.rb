class Chat::RoomsController < ApplicationController
  
  def index
    @rooms = Chat::Room.all
    @rooms = [] unless current_user
    respond_to do |format|
      format.json { render json: @rooms.to_json }
    end
  end
  
  def subscribed
    current_user.rooms
    respond_to do |format|
      format.json { render json: @rooms.to_json }
    end
  end
  
  def form
    @room = Chat::Room.find(params[:id])
    respond_to do |format|
      format.html { render partial: "form" }
    end
  end
  
end