class FaqsController < ApplicationController

  def index
    authorize! :read, Faq
    @faqs = Faq.all.order_by(:position,:asc)
    @faq = Faq.new
  end
  
  def create
    @faq = Faq.new(params[:faq])
    @faq.position = Faq.count + 1
    respond_to do |format|
      if @faq.save
        format.js { render :partial => 'faq', locals: { faq: @faq } }
        format.html { redirect_to :back }
      end 
    end
  end
  
  def destroy
    @faq = Faq.find(params[:id])
    authorize! :destroy, @faq
    respond_to do |format|
      if @faq.destroy
        format.js { render :json => @faq }
        format.html { redirect_to :back }
      end 
    end
  end
  
  def update
    @faq = Faq.find(params[:id])
    authorize! :update, @faq
    
    respond_to do |format|
      if @faq.update_attributes(params[:faq])
        format.json { respond_with_bip(@faq) }
        format.html { redirect_to :back }
      end 
    end
  end
  
  def sort_figures
    @figures = ActiveSupport::JSON.decode(params[:figures])
    @figures.each do |figure|
      Faq.where(_id: figure['id']).update_all(position: figure['position'])
    end
    respond_to do |format|
      format.json { render :nothing => true }
    end
  end

end
