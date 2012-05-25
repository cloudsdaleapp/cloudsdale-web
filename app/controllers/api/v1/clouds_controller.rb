class Api::V1::CloudsController < Api::V1Controller
  
  # Public: Fetches a cloud from supplised id parameter
  # Returns the cloud.
  def show
    
    @cloud = Cloud.find(params[:id])
    authorize! :read, @cloud
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
    authorize! :update, @cloud
    
    @cloud.write_attributes(params[:cloud], as: @cloud.get_role_for(current_user))
        
    if @cloud.save
      render status: 200
    else
      set_flash_message message: "Something went wrong while updating the cloud. Please look over your input.", title: "The horror!"
      build_errors_from_model @user
      render status: 422
    end
    
  end
  
  # Public: Get the 10 most popular Clouds based on member count.
  # Returns a collection of Clouds.
  def popular
    
    @clouds = Cloud.popular.limit(10)
    render status: 200
    
  end
  
  # Public: Gets the 10 most recent Clouds in chronological order.
  # Returns a collection of Clouds.
  def recent
    
    @clouds = Cloud.recent.limit(10)
    render status: 200
    
  end
  
  # Public: Searches the Cloud collection based on a query parameter.
  #
  #   q - The query parameter
  #
  # Returns a collection of Clouds.
  def search
    
    @query = params[:q] || ""
    
    @clouds = Cloud.fulltext_search @query, hidden: false
    render status: 200
    
  end
  
end