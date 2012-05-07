class RootController < ApplicationController
  
  skip_before_filter  :redirect_on_maintenance!,  only: [:maintenance]
  skip_after_filter   :render_root_page!,  only: [:maintenance,:index]
  
  def index
  end
  
  def not_found
    render status: 404
  end
  
  def server_error
    render status: 500
  end
  
  def unauthorized
    render status: 401
  end
  
  def maintenance
    render layout: false
  end

end
