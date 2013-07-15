class Api::V2Controller < ActionController::Base

  class ResourceUnauthorizedError < StandardError; end

  include ActionController::FrontAuth
  include Pundit
  include Arcane

  respond_to :json

  before_filter :cors_preflight_check
  after_filter  :cors_set_access_control_headers

  rescue_from ResourceUnauthorizedError do
    render_exception("You are not allowed to access this resource.", 401)
  end

  rescue_from Pundit::NotAuthorizedError do |message|
    render_exception("You're not allowed to do this. #{message}", 401)
  end

private

  def doorkeeper_unauthorized_render_options
    raise ResourceUnauthorizedError
  end

  def render_exception(message,status)
    add_error(type: :generic, message: message)
    respond_with_resource(nil, status: status)
  end

  def build_errors_from(model)
    return @errors if model.errors.empty?
    model.errors.messages.each do |field, messages|

      type    = model[:_type].try(:to_s)  ||
                model.class.to_s          ||
                String.new

      add_error(
        type:          :field,
        resource_type: type.downcase,
        resource_id:   model.id,
        resource_node: field.to_s,
        message:       messages.to_sentence
      )

    end

    return @errors
  end

  def add_error(type: :generic, resource_id: nil, resource_type: nil, resource_node: nil, message: "")
    error = HashWithIndifferentAccess.new
    error[:type]          = type
    error[:resource_id]   = resource_id   if resource_id
    error[:resource_type] = resource_type if resource_type
    error[:resource_node] = resource_node if resource_node
    error[:message]       = message

    errors.push(error)
  end

  def respond_with_resource(resource,opts)

    if resource.present?
      opts[:meta]     = errors if errors.any?
      opts[:meta_key] = :errors
    else
      resource    = errors
      opts[:root] = :errors
      opts[:serializer] = nil
    end

    respond_with(resource,opts)
  end

  def errors
    @errors ||= []
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    if request.method == :options
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
      headers['Access-Control-Max-Age'] = '1728000'
      render :text => '', :content_type => 'text/plain'
    end
  end

end
