class TagsController < ApplicationController
  
  def search
    
    @search = Tire.search(['tags']) do |s|
      s.query {|q| q.string params[:q]}
    end
    
    @results = @search.results
    
    unless @results.results.map{|t|t[:name].downcase}.include?(params[:q].downcase)
      @results.unshift Tag.new(name:params[:q]).to_indexed_json
    end
    
    respond_to do |format|
      format.json { render json: @results }
    end
  end
  
end