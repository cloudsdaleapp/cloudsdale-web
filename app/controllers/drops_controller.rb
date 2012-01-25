class DropsController < ApplicationController

  def create
    @depositable_ids = (current_user.publisher_ids + [current_user.id]).uniq + current_user.cloud_ids
    @drop = current_user.create_drop_deposit_from_url_by_user(params[:url],current_user)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render partial: 'drop', locals: { drop: @drop, deposits: @drop.deposits.any_of(:depositable_id.in => @depositable_ids), depositable: nil } }
    end
  end
  
  def search
    response.headers["search"] = 'true'
    
    case params[:sort]
    when 'rating'
      sort = ['votes.point',:desc]
    when 'visits'
      sort = ['total_visits', :desc]
    when 'recent'
      sort = ['updated_at', :desc]
    else
      sort = []
    end
    
    @q = !params[:q].empty? ? params[:q] : current_user.name
    unless @q.empty? or @q.nil?
      @search = Drop.tire.search :load => true, :page => (params[:page].to_i || 1), per_page: 10 do |s|
        s.query { |q| q.string "title:#{@q}" }
        unless sort.empty?
          s.sort  { by sort[0], sort[1] }
        end
      end
    else
    end
    
    @depositable_ids = (current_user.publisher_ids + [current_user.id]).uniq + current_user.cloud_ids
    @drops = @search.results
    
    respond_to do |format|
      format.html { }
      format.js { render partial: 'drops/list_content' }
    end
    
  end
  
end