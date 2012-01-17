class MainController < ApplicationController
  
  skip_before_filter :redirect_on_maintenance!, only: [:maintenance]
  
  before_filter only: [:index] do
    unless current_user
      redirect_to login_path
    end
  end
  
  def index
    @depositable_ids = (current_user.publisher_ids + [current_user.id]).uniq + current_user.cloud_ids
    
    case params[:sort]
    when 'top_rated'
      sort = ['votes.point',:desc]
    when 'most_viwed'
      sort = [:total_views,:desc]
    else
      sort = [:updated_at, :desc]
    end
    
    @drops = Drop.any_of(:"deposits.depositable_id".in => @depositable_ids).order_by(sort).limit(20)
  end
  
  def maintenance
    render layout: false
  end

end
