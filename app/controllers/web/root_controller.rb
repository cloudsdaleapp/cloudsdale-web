class Web::RootController < WebController

  def index
    render "index.#{determine_template}"
  end

  def not_found
    render 'exceptions/not_found.html.haml', status: 404
  end

private

  def determine_template
    current_user.new_record? ? 'front' : 'session'
  end

end
