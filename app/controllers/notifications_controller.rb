class NotificationsController < ApplicationController
  
  def index
    respond_to do |format|
      format.html { render json: current_user.notifications.unread }
    end
  end
  
  def show
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!
    redirect_to @notification.url
  end
  
end
