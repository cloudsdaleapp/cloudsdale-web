class SearchController < ApplicationController
  
  def create
    authorize! :search, :database
    
    @query = params[:q]
    
    @clouds = Tire.search('clouds') do |s|
      s.query { |q| q.string @query}
    end
    
    @entries = Tire.search(['articles']) do |s|
      s.query { |q| q.string @query}
    end

    @users = Tire.search('users') do |s|
      s.query { |q| q.string @query}
    end

    respond_to do |format|
      format.js { render json: { clouds: @clouds.results[0..2], entries: @entries.results[0..2], users: @users.results[0..2]} }
    end
    
  end

end