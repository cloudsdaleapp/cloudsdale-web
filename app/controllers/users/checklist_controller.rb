class Users::ChecklistController < ApplicationController
  
  before_filter do
    @user = User.find(params[:user_id])
    authorize! :checklist, @user
    @checklist = @user.checklist
  end
  
  def read_welcome_message
    @checklist.read_welcome_message = true
    respond_to do |format|
      if @checklist.save
        format.html { redirect_to :back }
        format.js { render json: ["200","ok"] }
      else
        raise "error"
      end
    end
  end
  
  def read_recruiting_message
    @checklist.read_recruiting_message = true
    respond_to do |format|
      if @checklist.save
        format.html { redirect_to :back }
        format.js { render json: ["200","ok"] }
      else
        raise "error"
      end
    end
  end
  
end