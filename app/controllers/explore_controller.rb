class ExploreController < ApplicationController
  
  before_filter do
  end
  
  def index
    @featured_clouds = Cloud.where(hidden: false, featured: true)
    @clouds = Cloud.where(hidden: false, featured: false).order_by(to_sort_params(params[:sort_by],params[:sort_order])).limit(18)
  end
  
  private
  
  def to_sort_params(sort_by,sort_order)
    sort_by ||= 'popularity'
    sort_order ||= 'desc'
    case sort_by
      when 'popularity'
        [:member_count,sort_order]
      when 'activity'
        [:created_at,sort_order]
      when 'timestamp'
        [:created_at,sort_order]
      else
        [:member_count,sort_order]
    end
  end
  
end