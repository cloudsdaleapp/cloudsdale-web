class NotificationsController < ApplicationController
  
  def index
    @notifications = current_user.notifications.all.sort{|a,b| (a[:read] == b[:read]) ? ((a[:timestamp] > b[:timestamp]) ? -1 : 1) : (a[:read] ? 1 : -1)}
    render partial: 'index'
  end
  
  def show
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read_and_save!
    redirect_to @notification.url
  end

end
