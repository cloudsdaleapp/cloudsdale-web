class Clouds::MembersController < ApplicationController
  
  before_filter do
    @cloud = Cloud.find(params[:cloud_id])
  end
  
  def create
    @cloud.users << current_user
    respond_to do |format|
      if @cloud.save
        format.html { redirect_to :back, :notice => notify_with(:success,"Jumped on #{@cloud.name}","") }
      else
        format.html { raise "#{@cloud.errors.first.to_s}" }
      end
    end
  end
  
  def destroy
    @cloud.users.delete(current_user)
    respond_to do |format|
      if @cloud.save
        format.html { redirect_to :back, :notice => notify_with(:warning,"Jumped off #{@cloud.name}","") }
      else
        format.html { raise "#{@cloud.errors.first.to_s}" }
      end
    end
  end
  
end