class Api::V1::Clouds::DropsController < Api::V1Controller
  
  # Fetches the the drops for the cloud with :cloud_id
  # this query can be paginated from a timestamp.
  #
  #
  #   headers - The headers you can use to modify your results:
  #
  #             X-Result-Page - An Integer used as an offset for the pagination.
  #             X-Result-Time - A DateTime timestamp of which you should fetch no records after.
  #   
  # Returns a Drops collection with 10 results at a time.
  #
  #   headers - The headers you can use to modify your next request:
  #
  #             X-Result-Page - An Integer used as an offset for the pagination.
  #             X-Result-Time - A DateTime timestamp of which you should fetch no records after.
  def index
    
    @page = request.headers["X_RESULT_PAGE"].to_i || 1
    @time = request.headers["X_RESULT_TIME"] ? Time.parse(request.header["X_RESULT_TIME"]) : Time.now
    
    @cloud = Cloud.find(params[:cloud_id])
    
    authorize! :read, @cloud
    
    @drops = Drop.only_visable.after_on_topic(@time,@cloud).order_by_topic(@cloud).page(@page).per(10)
        
    render status: 200
    
  end
  
  after_filter only: [:index] do
  # Fetches the the drops for the cloud with :cloud_id
  # based on :q search query.
  #
  #   cloud_id - The id of the clouds of where to scope the drop results.
  #   q - The query string of which to base the search result of.
  #
  # Returns a Drops collection.
  def search
    
    @cloud = Cloud.find(params[:cloud_id])
    @query = params[:q]
    
    authorize! :read, @cloud
    
    @drops = Drop.only_visable.fulltext_search(@query, depositable_ids: { any: [@cloud.id.to_s] })
    @drops = Kaminari.paginate_array(@drops).page(@page).per(10)
        
    render status: 200
    
    
    response.headers["X-Result-Page"] = @page.to_s
    
    response.headers["X-Result-Next"] = (@page + 1).to_s unless @drops.last_page?
    
    response.headers["X-Result-Prev"] = (@page - 1).to_s unless @drops.first_page?
    
    response.headers["X-Result-Time"] = @time.to_s
    
    response.headers["X-Result-Total"] = @drops.total_count.to_s
    
  end
  
end