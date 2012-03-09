class MainController < ApplicationController
  
  skip_before_filter :redirect_on_maintenance!, only: [:maintenance]
  
  before_filter only: [:index] do
    unless current_user
      redirect_to login_path
    end
  end
  
  def index
    @depositable_ids = (current_user.publisher_ids + [current_user.id]).uniq + current_user.cloud_ids
    @drops = Drop.only_visable.any_of(:"deposits.depositable_id".in => @depositable_ids).order_by('deposits.updated_at',:desc).page(params[:page] || 1).per(10)
    @suggested_clouds = Cloud.where(hidden: false, :user_ids.nin => [current_user.id]).order_by(:member_count,:desc).limit(3)
    respond_to do |format|
      format.html {  }
      format.js { render partial: 'drops/list_content' }
    end
  end
  
  def maintenance
    render layout: false
  end

end
