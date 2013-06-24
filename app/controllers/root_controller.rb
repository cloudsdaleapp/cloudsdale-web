class RootController < ApplicationController

  skip_before_filter  :redirect_on_maintenance!,  only: [:maintenance]

  def index
    render 'pages/_root.html.haml'
  end

  def not_found
    render 'exceptions/not_found.html.haml', status: 404
  end

end
