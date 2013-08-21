class CloudsController < ApplicationController

  def show

    @cloud = Cloud.lookup(params[:id])

    authorize @cloud, :show?

    @page_title = @cloud.name
    @page_image = @cloud.dynamic_avatar_url
    @page_description = @cloud.description
    @page_type = "cloudsdale:cloud"
    @page_url  = cloud_url(@cloud)

    if current_user.new_record?
      session[:redirect_url] = @page_url
      @session = Session.new
      render 'sessions/new', layout: 'auth'
    else
      render status: 200
    end

  end

end
