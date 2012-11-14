class CloudsController < ApplicationController

  def show
    @cloud = Cloud.find(params[:id])

    @page_title = "Cloudsdale - #{@cloud.name}"
    @page_image = @cloud.avatar.url
    @page_description = @cloud.description
    @page_type = "group"
    @page_url = cloud_url(@cloud.id)

    authorize! :read, @cloud
    render status: 200

  end

end
