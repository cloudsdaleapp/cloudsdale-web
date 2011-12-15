class SearchController < ApplicationController
  
  def create
    authorize! :search, :database
    
    @query = params[:q]
    
    @clouds = Cloud.tire.search(@query)
    @entries = []
    @users = User.tire.search(@query)

    respond_to do |format|
      format.js { render json: { clouds: @clouds, entries: @entries, users: @users} }
    end
    
  end

end