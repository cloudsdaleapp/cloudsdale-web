class DropsController < ApplicationController

  def create
    @drop = Drop.find_or_initialize_from_matched_url(params[:url])
    current_user.drops << @drop unless current_user.drop_ids.include?(@drop.id)
    respond_to do |format|
      if @drop.save
        format.html { redirect_to :back }
      else
        format.html { redirect_to :back }
      end
    end
  end

end