class MainController < ApplicationController
  
  before_filter only: [:index] do
    unless current_user
      redirect_to login_path
    end
  end
  
  def index
    @ids = (current_user.subscriber_ids + [current_user.id]).uniq + current_user.cloud_ids
    @drops = Drop.any_of(:"deposits.depositable_id".in => @ids).order_by(:updated_at,:desc).limit(20)
  end

end
