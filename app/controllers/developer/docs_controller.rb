class Developer::DocsController < DeveloperController

  def index
  end

  def show
    @page_id   = params[:id]
    @page      = @page_id.to_s.gsub(/-/i,'_')
    @file      = Rails.root.join("app", "views", params[:controller], "_#{@page}.html.haml").to_s
    if File.exists?(@file)
      render status: 200
    else
      raise ActionController::RoutingError, "documentation page does not exist."
    end
  end

end
