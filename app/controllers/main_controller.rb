class MainController < ApplicationController
  
  skip_before_filter :redirect_on_maintenance!, only: [:maintenance]
  
  before_filter only: [:index] do
    unless current_user
      redirect_to login_path
    end
  end
  
  def index
    @ids = (current_user.publishers_ids + [current_user.id]).uniq + current_user.cloud_ids
    @drops = Drop.any_of(:"deposits.depositable_id".in => @ids).order_by(:updated_at,:desc).limit(20)
  end
  
  def maintenance
    render layout: false
  end

end
