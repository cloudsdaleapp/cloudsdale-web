class Clouds::MembersController < ApplicationController
  
  before_filter do
    @cloud = Cloud.find(params[:cloud_id])
  end
  
  def create
    @cloud.users << current_user
    respond_to do |format|
      if @cloud.save
        format.html { redirect_to :back, notice: "Jumped on #{@cloud.name}" }
      else
        flash[:error] = errors_to_string(@cloud.errors)
        format.html { redirect_to :back }
      end
    end
  end
  
  def destroy
    @cloud.users.delete(current_user)
    respond_to do |format|
      if @cloud.save
        format.html { redirect_to :back, notice: "Jumped off #{@cloud.name}" }
      else
        flash[:error] = errors_to_string(@cloud.errors)
        format.html { redirect_to :back }
      end
    end
  end
  
end