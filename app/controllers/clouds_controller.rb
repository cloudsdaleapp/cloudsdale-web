class CloudsController < ApplicationController

  def show
    # @cloud = Cloud.find(params[:id_or_short_name]) or Cloud.where( short_name: params[:id_or_short_name]).first
    id_or_short_name = params[:id_or_short_name]
    @cloud = Cloud.where("$or" => [{id: id_or_short_name}, {short_name: id_or_short_name}]).first
    @page_title = "Cloudsdale - #{@cloud.name}"
    @page_image = @cloud.avatar.url
    @page_description = @cloud.description
    @page_type = "group"
    @page_url = cloud_url(@cloud.id)

    authorize! :read, @cloud
    render status: 200

  end

end
