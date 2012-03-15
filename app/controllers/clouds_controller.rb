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
    
    case params[:sort]
    when 'top_rated'
      sort = ['votes.point',:desc]
    when 'most_viwed'
      sort = [:total_views,:desc]
    else
      sort = ["deposits.#{@cloud.id}_updated_at", :desc]
    end
    
    @drops = Drop.only_visable.where("deposits.depositable_id" => @cloud.id).order_by(sort).page(params[:page] || 1).per(10)
    respond_to do |format|
      format.html {  }
      format.js { render partial: 'drops/list_content', locals: { depositable: @cloud } }
    end
  end
  
  def create
    @cloud = Cloud.new(params[:cloud])
    authorize! :create, @cloud
    @cloud.users << current_user
    @cloud.owner = current_user
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
        format.html { redirect_to :back }
      end
    end
  end
  
  
  # Toggles is the Cloud should be featured or not.
  # Featured Clouds appear at the top of the explore page.
  def feature
    @cloud = Cloud.find(params[:id])
    authorize! :feature, @cloud
    toggle = @cloud.featured? ? false : true
    respond_to do |format|
      if @cloud.update_attribute(:featured,toggle)
        format.html { redirect_to cloud_path(@cloud), notice: "#{@cloud.name} is #{ toggle ? "now" : "no longer" } featured." }
      else
        flash[:error] = "Cloud not #{toggle ? 'feature' : 'unfeature' } #{@cloud.name}, something went wrong."
        format.html { redirect_to :back }
      end
    end
  end
  
end