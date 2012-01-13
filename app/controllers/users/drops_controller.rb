class Users::DropsController < ApplicationController
  
  before_filter do
    @user = User.find(params[:user_id])
  end

  def create
    @drop = Drop.find_or_initialize_from_matched_url(params[:url])
    respond_to do |format|
      if @drop.save
        @deposit = @drop.deposits.find_or_initialize_by(depositable_id: @user.id, depositable_type: "User")
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