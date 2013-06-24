class Web::RootController < WebController

  def index
    if !current_user.new_record? && request.subdomain.match(/www/)
      render layout: 'application', template: 'pages/_root.html.haml'
    else
      render "index.#{determine_template}"
    end
  end

  def not_found
    render 'exceptions/not_found.html.haml', status: 404
  end

private

  def determine_template
    current_user.new_record? ? 'front' : 'session'
  end

end
