class CloudsController < ApplicationController

  def show

    id_or_short_name = params[:id_or_short_name]
    @cloud = Cloud.where("$or" => [{id: id_or_short_name}, {short_name: id_or_short_name}]).first

    @page_title = "Cloudsdale - #{@cloud.name}"
    @page_image = @cloud.avatar.url
    @page_description = @cloud.description
    @page_type = "cloudsdale:cloud"
    @page_url = @cloud.short_name.present? cloud_url(@cloud.short_name) : cloud_url(@cloud.id)

    authorize! :read, @cloud
    render status: 200

  end

end
