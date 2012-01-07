class Drops::VotesController < ApplicationController
  
  before_filter do
    @drop = Drop.find(params[:drop_id])
  end
  
  def create
    respond_to do |format|
      if current_user.vote(@drop,params[:value])
        format.html { redirect_to :back }
      else
        format.html { redirect_to :back }
      end
    end
  end
  
  def destroy
    respond_to do |format|
      if current_user.unvote(@drop)
        format.html { redirect_to :back }
      else
        format.html { redirect_to :back }
      end
    end
  end
  
end