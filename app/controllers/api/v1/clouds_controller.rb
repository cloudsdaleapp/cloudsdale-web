class Api::V1::CloudsController < Api::V1Controller
  
  # Public: Fetches a cloud from supplised id parameter
  # Returns the cloud.
  def show
    @cloud = Cloud.find(params[:id])
    authorize! :read, @cloud
    render status: 200
  end
  
end