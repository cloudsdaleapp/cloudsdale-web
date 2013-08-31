class Web::RootController < WebController

  def index
    if !current_user.new_record? && request.subdomain.match(/www/)
      render layout: 'application', template: 'pages/_root.html.haml'
    else
      render "index.#{determine_template}"
    end
  end

  def gaze
    render "gaze.#{determine_template}"
  end

  def not_found
    render layout: 'web.front', status: 404, template: 'exceptions/not_found.html.haml'
  end

private

  def determine_template
    current_user.new_record? ? 'front' : 'session'
  end

end
