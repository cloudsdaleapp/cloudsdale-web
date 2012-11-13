class RootController < ApplicationController

  skip_before_filter  :redirect_on_maintenance!,  only: [:maintenance]

  def index
    render 'pages/_root.html.haml'
  end

end
