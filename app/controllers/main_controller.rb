class MainController < ApplicationController
  
  def index
    if current_user
      @feartued_entry = Entry.where(promoted: true).first
      @recent_entries = Entry.order_by(:created_at,:desc).limit(5)
    end
  end

end
