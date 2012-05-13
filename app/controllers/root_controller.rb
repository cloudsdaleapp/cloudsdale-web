class RootController < ApplicationController
  
  skip_before_filter  :redirect_on_maintenance!,  only: [:maintenance]
  
  def index
  end
  
  def explore
  end
  
  def info
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
  
  def custom_error
    params[:title] = "Error" unless params[:title]
    params[:sub_title] = "Stop messing around with custom errors." unless params[:sub_title]
    
    render status: params[:status] ? params[:status] : 500
  end
  
  def maintenance
    render layout: false
  end

end
