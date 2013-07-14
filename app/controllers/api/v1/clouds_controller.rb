class Api::V1::CloudsController < Api::V1Controller

  #   headers - The headers you can use to modify your results:
  #
  #             X-Result-Page - An Integer used as an offset for the pagination.
  #             X-Result-Time - A DateTime timestamp of which you should fetch no records after.
  #
  before_filter only: [:popular,:recent,:search] do

    @page = request.headers["X_RESULT_PAGE"].to_i || 1
    @time = request.headers["X_RESULT_TIME"] ? Time.parse(request.headers["X_RESULT_TIME"]) : Time.now
    @per =  request.headers["X_RESULT_PER"]  ? request.headers["X_RESULT_PER"].to_i : 10

  end

  # Public: Fetches a cloud from supplied id OR short name parameter
  # Returns the cloud.
  def show

    @cloud = Cloud.agnostic_fetch(params[:id])
    authorize @cloud, :show?
    render status: 200

  end

  # Private: Accepts parameters to update a cloud object.
  # matching the given ID.
  #
  # id    - A BSON id of the cloud to update the attributes on.
  # cloud  - A Hash of parameters to send to the cloud object.
  #
  # Returns the cloud object with a status of 200 if successful & 422 if unsuccessful.
  def update

    @cloud = Cloud.find(params[:id])
    authorize @cloud, :update?

    @cloud.write_attributes(params[:cloud], as: @cloud.get_role_for(current_user))

    Conversation.about(@cloud, as: current_user).start

    if @cloud.save
      render status: 200
    else
      set_flash_message message: "Something went wrong while updating the cloud. Please look over your input.", title: "The horror!"
      build_errors_from_model @cloud
      render status: 422
    end

  end

  # Private: Accepts parameters to create a cloud object.
  # when saved the current user is added as the cloud owner.
  #
  # cloud  - A Hash of parameters to send to the cloud object.
  #
  # Returns the cloud object with a status of 200 if successful & 422 if unsuccessful.
  def create

    @cloud = Cloud.new(params[:cloud])

    authorize @cloud, :create?

    @cloud.owner = current_user
    @cloud.users << current_user
    @cloud.moderators << current_user

    if @cloud.save
      Conversation.about(@cloud, as: current_user).start
      render status: 200
    else
      set_flash_message message: "You could not create the Cloud. Please look over your input.", title: "What did you say?"
      build_errors_from_model @cloud
      render status: 422
    end

  end

  # Private: Accepts request to destroy a cloud.
  #
  # id    - A BSON id of the cloud to update the attributes on.
  #
  # Returns the cloud object with a status of 200 if successful & 422 if unsuccessful.
  def destroy

    @cloud = Cloud.find(params[:id])

    authorize @cloud, :destroy?

    if @cloud.destroy
      Conversation.about(@cloud, as: current_user).stop
      render status: 200
    else
      set_flash_message message: "Could not delete this Cloud, please contact a system administrator.", title: "I will destroy you!"
      build_errors_from_model @cloud
      render status: 422
    end

  end

  # Public: Get the 10 most popular Clouds based on member count.
  # Returns a collection of Clouds.
  def popular

    @clouds = Cloud.visible.popular.without(:user_ids,:moderator_ids).page(@page).per(@per)
    render status: 200

  end

  # Public: Gets the 10 most recent Clouds in chronological order.
  # Returns a collection of Clouds.
  def recent

    @clouds = Cloud.visible.recent.without(:user_ids,:moderator_ids).page(@page).per(@per)
    render status: 200

  end

  # Public: Searches the Cloud collection based on a query parameter.
  #
  #   q - The query parameter
  #
  # Returns a collection of Clouds.
  def search

    @query = params[:q] || ""

    @clouds = Cloud.fulltext_search(@query, hidden: false)
    @clouds = Kaminari.paginate_array(@clouds).page(@page).per(@per)
    render status: 200

  end

  # Returns a Clouds collection with 10 results at a time.
  #
  #   headers - The headers you can use to modify your next request:
  #
  #             X-Result-Page - An Integer used as an offset for the pagination.
  #             X-Result-Time - A DateTime timestamp of which you should fetch no records after.
  #
  after_filter only: [:popular,:recent,:search] do

    response.headers["X-Result-Per"]  = @per.to_s || "10"
    response.headers["X-Result-Page"] = @page.to_s
    response.headers["X-Result-Next"] = (@page + 1).to_s unless @clouds.last_page?
    response.headers["X-Result-Prev"] = (@page - 1).to_s unless @clouds.first_page?
    response.headers["X-Result-Time"] = @time.to_s
    response.headers["X-Result-Total"] = @clouds.total_count.to_s

  end

end
