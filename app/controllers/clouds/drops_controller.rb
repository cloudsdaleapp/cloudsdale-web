class Clouds::DropsController < ApplicationController
  
  before_filter do
    @cloud = Cloud.find(params[:cloud_id])
  end

  def create
    @drop = @cloud.create_drop_deposit_from_url_by_user(params[:url],current_user)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render partial: 'drops/drop', locals: { drop: @drop, deposits: @drop.deposits.where(:depositable_id => @cloud.id), depositable: @cloud } }
    end
  end
  
end