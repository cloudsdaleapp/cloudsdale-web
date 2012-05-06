class RootController < ApplicationController
  
  skip_before_filter  :redirect_on_maintenance!,  only: [:maintenance]
  skip_after_filter   :render_root_page!
  
  def index
  end
  
  def maintenance
    render layout: false
  end

end
