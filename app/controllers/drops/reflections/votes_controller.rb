class Drops::Reflections::VotesController < ApplicationController
  
  before_filter do
    @drop = Drop.find(params[:drop_id])
  end
  
  def create
    respond_to do |format|
      if false
        # format.js { render partial: 'drops/reflections/votes', locals: { drop: @drop } }
      end
    end
  end
  
  def destroy
    respond_to do |format|
      if false
        # format.js { render partial: 'drops/reflections/votes', locals: { drop: @drop } }
      end
    end
  end
  
end