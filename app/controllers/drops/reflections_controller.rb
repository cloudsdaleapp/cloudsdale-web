class Drops::ReflectionsController < ApplicationController
  
  before_filter do
    @drop = Drop.find(params[:drop_id])
  end
  
  def create
    @reflection = @drop.reflections.build(params[:reflection])
    @reflection.author = current_user
    authorize! :create, @reflection
    respond_to do |format|
      if @reflection.save
        format.js { render :partial => 'drops/reflections/show', locals: { reflection: @reflection } }
      else
        format.js { render json: {} }
      end
    end
  end
  
  def destroy
    @reflection = @drop.reflections.find(params[:id])
    authorize! :destroy, @reflection
    respond_to do |format|
      if @reflection.destroy
        second_best_reflection = @drop.reflections.first
        format.js { render :json => { reflection: @reflection, second_best_reflection: second_best_reflection } }
       else
        format.js { render json: {} }
      end
    end
  end
  
end