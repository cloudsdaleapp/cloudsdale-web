class Api::V1::Clouds::DropsController < Api::V1Controller

  #   headers - The headers you can use to modify your results:
  #
  #             X-Result-Page - An Integer used as an offset for the pagination.
  #             X-Result-Time - A DateTime timestamp of which you should fetch no records after.
  #
  before_filter only: [:index,:search] do

    @page = request.headers["X_RESULT_PAGE"].to_i || 1
    @time = request.headers["X_RESULT_TIME"] ? Time.parse(request.headers["X_RESULT_TIME"]) : Time.now

  end

  # Fetches the the drops for the cloud with :cloud_id
  # this query can be paginated from a timestamp.
  #
  #   cloud_id - The id of the clouds of where to scope the drop results.
  #
  # Returns a Drops collection with 10 results at a time.
  def index

    @cloud = Cloud.find(params[:cloud_id])

    authorize @cloud, :show?

    @drops = [] # Drop.only_visable.after_on_topic(@time,@cloud).order_by_topic(@cloud).page(@page).per(10)
    @drops = Kaminari.paginate_array(@drops).page(@page).per(10)

    render status: 200

  end

  # Fetches the the drops for the cloud with :cloud_id
  # based on :q search query.
  #
  #   cloud_id - The id of the clouds of where to scope the drop results.
  #   q - The query string of which to base the search result of.
  #
  # Returns a Drops collection.
  def search

    @cloud = Cloud.find(params[:cloud_id])
    @query = params[:q] || ""

    authorize @cloud, :show?

    @drops = [] # Drop.only_visable.fulltext_search(@query, depositable_ids: { any: [@cloud.id.to_s] })
    @drops = Kaminari.paginate_array(@drops).page(@page).per(10)

    render status: 200
  end

  # Private: Accepts request to destroy a drop.
  #
  # cloud_id - A BSON id of the cloud owning the drop (technically not necessary I guess)
  # id    - A BSON id of the drop to kill.
  #
  # Returns the drop object with a status of 200 if successful & 422 if unsuccessful.
  def destroy

    @cloud = Cloud.find(params[:cloud_id])
    @drop = Drop.find(params[:id])
    authorize @drop, :destroy?

    if @drop.destroy
      render status: 200
    else
      set_flash_message message: "Could not delete this Drop, please contact a system administrator.", title: "I will destroy you!"
      build_errors_from_model @drop
      render status: 422
    end

  end

  # Returns a Drops collection with 10 results at a time.
  #
  #   headers - The headers you can use to modify your next request:
  #
  #             X-Result-Page - An Integer used as an offset for the pagination.
  #             X-Result-Time - A DateTime timestamp of which you should fetch no records after.
  #
  after_filter only: [:index,:search] do

    response.headers["X-Result-Page"] = @page.to_s
    response.headers["X-Result-Next"] = (@page + 1).to_s unless @drops.last_page?
    response.headers["X-Result-Prev"] = (@page - 1).to_s unless @drops.first_page?
    response.headers["X-Result-Time"] = @time.to_s
    response.headers["X-Result-Total"] = @drops.total_count.to_s

  end

end
