class MainController < ApplicationController
  
  before_filter only: [:index] do
    unless current_user
      redirect_to login_path
    end
  end
  
  def index
    
    authorize! :read, Entry
    
    @featured_entry = Entry.where(promoted: true).first
    @popular_clouds = Cloud.where(hidden: false).order_by([:member_count,:desc]).limit(6)
    @recent_clouds = Cloud.where(hidden: false).order_by([:created_at,:desc]).limit(6)

    case params[:tab]
      when nil
        @entries = Entry.where(published: true, hidden: false, promoted: false).order_by(:published_at,:desc).limit(10)
      when "subscriptions"
        @entries = Entry.any_in(author_id: current_user.publisher_ids).order_by([:published_at,:desc]).limit(10)
      when "popular"
        @entries = Entry.where(published: true, hidden: false, promoted: false, :published_at.gt => 7.days.ago).order_by([:views,:desc],[:comments,:desc],[:published_at,:desc]).limit(10)
    end

  end

end
