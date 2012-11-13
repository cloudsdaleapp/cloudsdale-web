class PagesController < ApplicationController

  layout :determine_layout

  def show
    @static_page = params[:page_id].to_s.gsub(/-/i,'_')
    render status: determine_status_for(@static_page)
  end

  private

  def determine_layout
    params[:layout] ? ((params[:layout] == "false") ? false : params[:layout]) : 'application'
  end

  def determine_status_for(static_page)
    if File.exists?(Rails.root.join("app", "views", params[:controller], "_#{static_page}.html.haml"))
      return 200
    else
      return 404
    end
  end

end
