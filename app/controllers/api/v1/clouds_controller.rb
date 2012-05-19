class Api::V1::CloudsController < Api::V1Controller
  
  # Public: Fetches a cloud from supplised id parameter
  # Returns the cloud.
  def show
    @cloud = Cloud.find(params[:id])
    authorize! :read, @cloud
    render status: 200
  # Private: Accepts parameters to update a cloud object.
  # matching the given ID.
  #
  # id    - A BSON id of the cloud to update the attributes on.
  # cloud  - A Hash of parameters to send to the cloud object.
  #
  # Returns the cloud object with a status of 200 if successful & 422 if unsuccessful.
  def update
    
    @cloud = Cloud.find(params[:id])
    authorize! :read, @cloud
    
    if @cloud.update_attribites(params[:cloud], as: @cloud.get_role_for(current_user))
      render status: 200
    else
      render status: 422
    end
    
  end
  end
  
end