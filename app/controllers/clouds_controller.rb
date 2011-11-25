class CloudsController < ApplicationController
  
  before_filter do
  end
  
  def new
    @cloud = Cloud.new
    authorize! :create, @cloud
  end
  
  def edit
    @cloud = Cloud.find(params[:id])
    authorize! :update, @cloud
  end
  
  def show
    @cloud = Cloud.find(params[:id])
    authorize! :read, @cloud
  end
  
  def create
    u = User.find(current_user.id)
    @cloud = Cloud.new(params[:cloud])
    u.clouds << @cloud
    authorize! :create, @cloud
    respond_to do |format|
      if @cloud.save
        format.html { redirect_to cloud_path(@cloud),
                                  notice: notify_with(:success,"#{@cloud.name}","was successfully created.")
                    }
      else
        format.html { render :new }
      end
    end
  end
  
  def update
    @cloud = Cloud.find(params[:id])
    authorize! :update, @cloud
    respond_to do |format|
      if @cloud.update_attributes(params[:cloud])
        format.html { redirect_to cloud_path(@cloud),
                                  notice: notify_with(:success,"#{@cloud.name}","was successfully updated.")
                    }
      else
        format.html { render :edit }
      end
    end
  end
  
  def destroy
    @cloud = Cloud.find(params[:id])
    authorize! :destroy, @cloud
    respond_to do |format|
      if @cloud.destroy
        format.html { redirect_to root_path,
                                  notice: notify_with(:notice,"#{@cloud.name}","was successfully destroyed.")
                    }
      else
        format.html { redirect :back }
      end
    end
  end
  
end