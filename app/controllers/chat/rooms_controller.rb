class Chat::RoomsController < ApplicationController
  
  def index
    @rooms = Chat::Room.all
    @rooms = [] unless current_user
    respond_to do |format|
      format.json { render json: @rooms.to_json }
    end
  end
  
end