class AdminController < ApplicationController
  
  before_filter do
    authorize! :reach, :admin_panel
  end
  
  def index
    @user_agents = UserAgent.all
  end
  
  def statistics
    
    dates = params[:date_range].split(' - ').map{ |d| d.to_datetime }
    
    @d1 = dates.first || DateTime.now
    @d2 = dates.last || @d1
    if @d1.beginning_of_day == @d2.beginning_of_day
      @d1 = @d1.yesterday
      @d2 = @d2.tomorrow
    end
    
    new_users = User.where(:member_since.gt => @d1.beginning_of_day, :member_since.lt => @d2.end_of_day)
    @new_users = []
    (@d1..@d2).each do |d|
      @new_users << new_users.where(:member_since.gt => d.beginning_of_day, :member_since.lt => d.end_of_day).count
    end
    
    total_users = User.all.only('member_since')
    @total_users = []
    (@d1..@d2).each do |d|
      @total_users << total_users.where(:member_since.lt => d.end_of_day).count
    end
    
    respond_to do |format|
      format.js { render partial: 'statistics' }
    end
    
  end
  
end