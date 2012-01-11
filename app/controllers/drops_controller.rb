class DropsController < ApplicationController

  def create
    @drop = Drop.find_or_initialize_from_matched_url(params[:url])
    
    @drop.users << current_user unless current_user.drop_ids.include?(@drop.id)

    #content = render(:partial => 'drops/drop', locals: { drop: drop }).html_safe
    #faye_broadcast "/dropzone/#{current_user.id}", { pending_id:, content: content }
    
    respond_to do |format|
      if @drop.save
        @deposit = current_user.deposits.find_or_create_by(drop_id: @drop.id)
        unless @deposit.new_record?
          @deposit.updated_at = Time.now
          @deposit.save
        end
        format.html { redirect_to :back }
        format.js { render partial: 'drop', locals: { drop: @drop } }
      else
        format.html { redirect_to :back }
      end
    end
  end
  
end