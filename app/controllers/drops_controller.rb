class DropsController < ApplicationController

  def create
    @drop = current_user.create_drop_deposit_from_url_by_user(params[:url],current_user)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render partial: 'drop', locals: { drop: @drop } }
    end
  end
  
end