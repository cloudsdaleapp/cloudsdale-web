class CloudsController < ApplicationController
  
  def show
    @cloud = Cloud.find(params[:id])
    authorize! :read, @cloud
  end
  
end