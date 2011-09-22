class PoniesController < ApplicationController
  
  before_filter :authenticated?
  
  def new
    @pony = current_user.ponies.build
  end

  def edit
    @pony = Pony.find(params[:id])
  end

  def show
    @pony = Pony.find(params[:id])
  end
  
  def create
    @pony = Pony.new(params[:pony])
    authorize! :create, @pony
    respond_to do |format|
      if @pony.save
        format.html { redirect_to @pony, :notice => 'A pony has been born.' }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    @pony = Pony.find(params[:id])
    authorize! :update, @pony
    respond_to do |format|
      if @pony.update_attributes(params[:pony])
        format.html { redirect_to @pony, :notice => 'Pony got as successfull makeover.' }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @pony = Pony.find(params[:id])
    authorize! :destroy, @pony
    respond_to do |format|
      if @pony.destroy
        format.html { redirect_to pony_path, :notice => 'Pony was brutally murdered.' }
      else
        format.html { render root_path }
      end
    end
  end

end
