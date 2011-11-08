class MainController < ApplicationController
  
  def index
    if current_user
      @feartued_entry = Entry.where(promoted: true).first
      @recent_entries = Entry.where(published: true, hidden: false).order_by(:updated_at,:desc).limit(5)
    end
  end

end
