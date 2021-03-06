class Api::V1Controller < ActionController::Base

  include Pundit
  include ActionController::FrontAuth

  layout :determine_layout

  before_filter :auth_token
  before_filter :record_user_activity
  after_filter :build_response_headers

  helper_method :errors

  # Rescues the error yielded from not finding requested document
  rescue_from Mongoid::Errors::DocumentNotFound do |message|
    render_exception "#{message} You sure this was what you were looking for?", 404
  end

  # Rescues the error from not being authorized to perform an action
  rescue_from Pundit::NotAuthorizedError do |message|
    render_exception "You're not allowed to do this. #{message}", 401
  end

  # Rescues the errors yielded by supplying a faulty BSON id
  rescue_from Moped::Errors::InvalidObjectId do |message|
    render_exception "BSON #{message}", 500
  end

protected

  # Public: Used to set a session for the user if the persist_session parameter is available.
  # It will also save the user to the database to ensure any new SHIT added to the user model
  # is persisted.
  def authenticate!(user)
    if params[:persist_session] == "true"
      cookies.signed[:auth_token] = {
        :domain =>  Figaro.env.session_key!,
        :value =>   user.auth_token,
        :expires => 20.years.from_now
      }
      @auth_token   = user.auth_token
      @current_user = user
    end
    user.save
  end

  # Protected: Determines if the client doing the API call is an
  # authorized client - This means the client has access to inhouse
  # methods in the API.
  #
  # Examples
  #
  # INTERNAL_TOKEN
  # # => "1234"
  #
  # request.env['X_AUTH_INTERNAL_TOKEN']
  # # => "1234"
  #
  # authorized_client?
  # # => true
  #
  # Returns a TrueClass or FalseClass depending on the state on the client of the current request.
  def authorized_client?
    request.env['X_AUTH_INTERNAL_TOKEN'] == INTERNAL_TOKEN
  end


  # Protected: Determines which layout to use based on the
  # requested content type.
  #
  # Examples
  #
  # class SomeController < SomeOtherController
  #
  # layout :determine_layout
  #
  # end
  #
  # Returns a string with the layout name
  def determine_layout
    case request.format
    when /html/
      'api_v1.html'
    when /xml/
      'api_v1.xml'
    else
      'api_v1.json'
    end
  end

  # Protected: Renders an exception back to the caller with a message and a status code.
  #
  # Examples
  #
  # render_exception "Not found", 404
  #
  # Returns a pretty render.
  def render_exception(error_message, status_code=500)
    add_error message: error_message
    render 'api/v1/exceptions/exception', status: status_code
    return
  end

  # Protected: Sets the instance variable @flash_message to a hash
  # hash which defaults to { message: "", type: "notice", title: "Note" }
  #
  # options -   A Hash of options which defaults to ({}):
  #
  #               :message - The content of the flash message
  #               :type - The type of the flash message
  #               :title - The title of the flash message
  #
  #               :* -  Any other parameters can be added to the flash
  #               message, remember we only support the three stated above
  #
  # Examples
  #
  # set_flash_message message: "Foo", type: "bar", title: "BAZ"
  # # => { message: "Foo", type: "bar", title: "BAZ" }
  #
  # Returns a motherfucking Hash, do not inject, smoke it.
  def set_flash_message(options={})
    default_options = { message: "", type: "notice", title: "Note" }
    @flash_message = default_options.merge(options)
  end

  # Protected: helper method to help determine how many records
  # to fetch when fetching a collection based on the "limit"
  # parameter sent by the client. If a negative value is supplied
  # or if the limit parameter is nil, the method will return
  # the fallback_limit which is 1 by default.
  #
  # fallback - Integer of which limit to use if no limit parameter is supplied.
  # max - Integer of the maximum amount of records that are allowed to be fetched.
  #
  # Examples
  #
  # params[:limit] = 50
  #
  # User.all.limit record_limit(5,100)
  # # => 50
  #
  # User.all.limit record_limit(5,30)
  # # => 30
  #
  #
  # params[:limit] = -1
  #
  # User.all.limit record_limit(5)
  # # => 5
  #
  # Returns an integer.
  def record_limit( fallback = 0, max = nil )
    i = params[:limit].try(:to_i) || fallback
    i = i > max ? max : i if max
    i > 0 ? i : fallback
  end

  # Protected: Builds some generic response headers, among them
  # X-Auth-Token // If a current user is present
  #
  # Examples
  #
  # after_filter :build_response_headers
  #
  # Returns "ok".
  def build_response_headers
    response.headers['X-Auth-Token'] = current_user.auth_token unless current_user.new_record?
    "ok"
  end

  # Protected: Used to build an error
  #
  # args -  The attributes from which the method will build the error.
  #           :type     - The type of error, should be: :general, :field
  #                       Defaults to :general .
  #
  #           :ref_id   - The id of the node to reference, eg. '4f2fd644b679de2228000007'
  #                       Defaults to nil.
  #
  #           :ref_type - The type of the node to reference, eg. 'cloud'
  #                       Defaults to nil.
  #
  #           :ref_node - The node of the reference object which is errorous, eg. a field name.
  #                       Defaults to nil.
  #
  #           :message  - The message to display to the user.
  #                       Defaults to an empty String.
  #
  # Returns the error hash which can in turn be rendered in a response
  def add_error(args={})
    defaults = { type: :general, ref_type: nil, ref_id: nil, ref_node: nil, message: '' }
    error = defaults.merge(args)
    errors << error
    return error
  end

  # Protected: Used to extract error messages from a errorous model
  # and compile them to be rendered in API responses.
  #
  # model - The model to extract the errors from.
  #
  # Examples
  #
  # build_errors_from_model @cloud
  # # => [{ :type => :field, :ref_type => 'user', :ref_id => '4f2fd644b679de2228000007', :ref_node => 'name', :message => 'can't be blank' }]
  #
  # Returns the array of error hashes which can be rendered in a response.
  def build_errors_from_model(_model)

    unless _model.errors.empty?

      _model.errors.messages.each do |field,messages|
        id    = _model[:_id].to_s
        type  = _model[:_type].try(:to_s) || _model.class.to_s.downcase || ""
        node  = field.to_s
        message = messages.join(', ')

        add_error type: :field, ref_type: type.downcase, ref_id: id, ref_node: node, message: message
      end

    end

    return errors
  end

  # Protected: Accessor for the errors variable.
  #
  # Returns the errors array.
  def errors
    @errors ||= []
  end


private

  # Private: Used to set an activity timestamp of a user
  #
  # Returns nothing of interest.
  def record_user_activity
    current_user.seen! ip: request.remote_ip unless current_user.new_record?
  end

end
