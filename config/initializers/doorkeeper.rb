module Doorkeeper
  module Errors
    class UnsupportedGrantType < DoorkeeperError
    end
  end

  module Helpers
    module Controller

      def get_error_response_from_exception(exception)
        error_name = case exception
        when Errors::InvalidTokenStrategy
          :unsupported_grant_type
        when Errors::InvalidAuthorizationStrategy
          :unsupported_response_type
        when Errors::MissingRequestStrategy
          :invalid_request
        when Errors::UnsupportedGrantType
          :unsupported_grant_type
        end

        OAuth::ErrorResponse.new :name => error_name, :state => params[:state]
      end

    end
  end
end

Doorkeeper.configure do

  orm :mongoid3

  resource_owner_authenticator do
    if current_user.new_record?
      session[:redirect_url] = request.fullpath
      redirect_to(login_path)
    else
      current_user
    end
  end

  admin_authenticator do
    if current_user.is_of_role?(:admin)
      current_user
    else
      redirect_to(root_path)
    end
  end

  # Allow for Official Cloudsdale applications to use user credentials to receive
  # oAuth access tokens. Especially good to keep phone and desktop apps consistant,
  # with the oAuth spec.
  resource_owner_from_credentials do |routes|
    if @server.client
      if @server.client.application.try(:official?)
        identifier = params[:identifier] || params[:username] || params[:password]
        @session = Session.new(identifier: identifier, password: params[:password])
        @session.user if @session.valid?
      else
        raise Doorkeeper::Errors::UnsupportedGrantType
      end
    end
  end

  # Authorization Code expiration time (default 10 minutes).
  authorization_code_expires_in 10.minutes

  # Access token expiration time (default 2 hours).
  # If you want to disable expiration, set this to nil.
  access_token_expires_in nil

  # Issue access tokens with refresh token (disabled by default)
  # use_refresh_token

  # Provide support for an owner to be assigned to each registered application (disabled by default)
  # Optional parameter :confirmation => true (default false) if you want to enforce ownership of
  # a registered application
  # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
  enable_application_owner :confirmation => false

  # Define access token scopes for your provider
  # For more information go to https://github.com/applicake/doorkeeper/wiki/Using-Scopes
  default_scopes  :read
  optional_scopes :chat

  # Change the way client credentials are retrieved from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:client_id` and `:client_secret` params from the `params` object.
  # Check out the wiki for more information on customization
  # client_credentials :from_basic, :from_params

  # Change the way access token is authenticated from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
  # Check out the wiki for mor information on customization
  # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

  # Change the test redirect uri for client apps
  # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
  # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
  # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
  #
  # test_redirect_uri 'urn:ietf:wg:oauth:2.0:oob'

  # Under some circumstances you might want to have applications auto-approved,
  # so that the user skips the authorization step.
  # For example if dealing with trusted a application.
  skip_authorization do |resource_owner, client|
    client.application.official?
  end

end

# Extend Doorkeeper models
Doorkeeper::Application.send(:include, Doorkeeper::Application::CloudsdaleExtention)
