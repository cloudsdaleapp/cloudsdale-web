class Api::V2Controller < ActionController::Base

  class ResourceUnauthorizedError < StandardError; end

  include ActionController::CORSProtection
  include ActionController::FrontAuth
  include Pundit
  include Arcane

  respond_to :json

  rescue_from ActionController::ParameterMissing do |exception|
    render_exception("#{exception.message}", 422)
  end

  rescue_from ResourceUnauthorizedError do
    render_exception("You are not allowed to access this resource.", 401)
  end

  rescue_from Pundit::NotAuthorizedError do |exception|
    render_exception("You're #{exception.message}.", 401)
  end

  rescue_from Mongoid::Errors::DocumentNotFound do |exception|
    render_exception("Sorry, could not find a #{exception.klass} with id #{exception.params}", 404)
  end

  rescue_from AbstractController::ActionNotFound do |exception|
    render_exception("Route unknown, please contact Cloudsdale staff for support.", 404)
  end


private

  def doorkeeper_unauthorized_render_options
    raise ResourceUnauthorizedError
  end

  def render_exception(message, status)
    add_error(type: :generic, message: message)
    respond_with_errors(status: status)
  end

  def respond_with_errors(opts={})
    set_cors
    json = ActiveModel::ArraySerializer.new(errors, each_serializer: ErrorSerializer, root: :errors).to_json
    opts = { json: json, status: 422 }.merge(opts)
    render opts
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
        resource_attr: field.to_s,
        message:       messages.to_sentence
      )

    end

    return @errors
  end

  def add_error(type: :generic, resource_id: nil, resource_type: nil, resource_attr: nil, message: "")
    error = Error.new
    error.type          = type
    error.resource_id   = resource_id
    error.resource_type = resource_type
    error.resource_attr = resource_attr
    error.message       = message
    errors.push(error)
    return error
  end

  def respond_with_resource(resource, opts)

    unless opts[:root] == :errors
      opts[:meta]     = errors if errors.any?
      opts[:meta_key] = :errors
    end
    opts[:location] = nil

    respond_with(resource, opts)
  end

  def errors
    @errors ||= []
  end

  def error_url(url)
  end

end
