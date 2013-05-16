class Developer::RootController < DeveloperController

  def index
  end

  def not_found
    render 'exceptions/not_found.html.haml', status: 404
  end

end
