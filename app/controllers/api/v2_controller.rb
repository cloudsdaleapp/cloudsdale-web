class Api::V2Controller < ActionController::Base

  class ResourceUnauthorizedError < StandardError; end

  include Pundit

  respond_to :json

  rescue_from ResourceUnauthorizedError do
    render_exception "You are not allowed to access this resource", 401
  end

  rescue_from Pundit::NotAuthorizedError do |message|
    render_exception "You're not allowed to do this. #{message}", 401
  end

private

  def doorkeeper_unauthorized_render_options
    raise ResourceUnauthorizedError
  end

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def render_exception(message,status)
    resp = {
      :meta => {
        :notice => message,
        :status => status
      }
    }
    respond_with resp, status: status
  end

end
