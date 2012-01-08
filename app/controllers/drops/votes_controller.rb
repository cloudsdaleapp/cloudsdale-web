class Drops::VotesController < ApplicationController
  
  before_filter do
    @drop = Drop.find(params[:drop_id])
  end
  
  def create
    respond_to do |format|
      if current_user.vote(@drop,params[:value])
        format.html { redirect_to :back }
        format.js { render partial: 'drops/votes/vote_links', locals: { drop: @drop } }
      end
    end
  end
  
  def destroy
    respond_to do |format|
      if current_user.unvote(@drop)
        format.html { redirect_to :back }
        format.js { render partial: 'drops/votes/vote_links', locals: { drop: @drop } }
      end
    end
  end
  
end