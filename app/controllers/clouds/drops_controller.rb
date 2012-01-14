class Clouds::DropsController < ApplicationController
  
  before_filter do
    @cloud = Cloud.find(params[:cloud_id])
  end

  def create
    @drop = Drop.find_or_initialize_from_matched_url(params[:url])
    respond_to do |format|
      if @drop.save
        @deposit = @drop.deposits.find_or_initialize_by(depositable_id: @cloud.id, depositable_type: "Cloud")
        @deposit.depositers << current_user unless @deposit.depositer_ids.include?(current_user.id)
        @deposit.save
        format.html { redirect_to :back }
        format.js { render partial: 'drops/drop', locals: { drop: @drop } }
      else
        format.html { redirect_to :back }
      end
    end
  end
  
end