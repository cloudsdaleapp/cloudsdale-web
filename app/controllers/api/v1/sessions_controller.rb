class Api::V1::SessionsController < Api::V1Controller
    
  # Public: Creates a redis backed session for the requesting client if
  # CSRF token is available. Otherwise the application stays stateless.
  # If the oAuth hash is supplied it will override the email & password
  # parameters and try authenticating with those insted. If authentication
  # fails, it will fall back on email & password if supplied.
  #
  # email - The registered email for a user
  # password - The password associated with that user
  #
  # oauth - A hash:
  #         :provider - String with the service oAuth provider
  #                     Can either be "facebook" or "twitter"
  #
  #         :uid -      String with the user id with the provider
  #
  #         :token -    String with the secret token for the user to allow the
  #                     application to access and authenticate.
  #
  #         :cli_type - String with the type of the client.
  #                     Currently supports "ios" or "android"
  # 
  # TODO: Implement Facebook & Twitter api connectors.
  #
  # Returns the the session template defined in 'views/api/v1/sessions/base.rabl'.
  def create
    
    @current_user = User.authenticate(
      email: params[:email],
      password: params[:password],
      oauth: params[:oauth]
    )
    
    if @current_user
      render status: 200
    else
      render_exception "User could not be authenticated.", 403
    end
    
  end
  
  # Public: Destroy the session
  #
  # Returns the the session template defined in 'views/api/v1/sessions/base.rabl'.
  #def destroy
    # destroy session and return session data
  #end
  
end