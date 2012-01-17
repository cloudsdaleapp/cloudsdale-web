class DropsController < ApplicationController

  def create
    @depositable_ids = (current_user.publisher_ids + [current_user.id]).uniq + current_user.cloud_ids
    @drop = current_user.create_drop_deposit_from_url_by_user(params[:url],current_user)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render partial: 'drop', locals: { drop: @drop, deposits: @drop.deposits.any_of(:depositable_id.in => @depositable_ids), depositable: nil } }
    end
  end
  
end