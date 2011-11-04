class TagsController < ApplicationController
  
  def search
    respond_to do |format|
      @tags = Tag.search("*#{params[:q]}*").results.map {|t|{id:t._id,name:t.name,times_referred: t.times_referred}}
      unless @tags.map{|t|t[:name]}.include?(params[:q])
        @tags.unshift Tag.new(name:params[:q]).token_inputs
      end
      format.json { render json: @tags }
    end
  end
  
end