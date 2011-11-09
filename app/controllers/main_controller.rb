class MainController < ApplicationController
  
  def index
    if current_user
      @feartued_entry = Entry.where(promoted: true).first
      @recent_entries = Entry.where(published: true, hidden: false).order_by(:updated_at,:desc).limit(5)
      @popular_entries = Entry.where(published: true, hidden: false, :updated_at.gt => 3.days.ago).order_by([:views,:desc],[:comments,:desc],[:updated_at,:desc]).limit(5)
    end
  end

end
