module ExploreHelper

  def param_queries(for_link,options={})
    sort_by       = { sort_by: params[:sort_by].present? ? params[:sort_by] : nil }
    sort_order    = { sort_order: (params[:sort_order] == 'desc' && params[:sort_by].present? && (for_link.to_s == params[:sort_by])) ? 'asc' : 'desc' }
    presentation  = { presentation: params[:presentation].present? ? params[:presentation] : nil}
    
    sort_by.merge(sort_order).merge(presentation).merge(options)
  end

end