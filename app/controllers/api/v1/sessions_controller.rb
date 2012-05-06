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
  # oauth - A Hash:
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
  # Returns the session template defined in 'views/api/v1/sessions/base.rabl'.
  def create
    
    @current_user = User.authenticate(
      email: params[:email],
      password: params[:password],
      oauth: params[:oauth]
    )
    
    
    # FIX ME - DO NOT DO THIS.
    # PLEEEEEEEAAAAAAAASSSSEEEEE!
    if params[:oauth]
      render_exception "You don't have access to this service.", 403 if params[:oauth][:token] != INTERNAL_TOKEN
    end
    
    if @current_user
      
      if !@current_user.has_a_valid_authentication_method? && params[:oauth]
        set_flash_message(
            message: "Could not connect #{params[:oauth][:provider]} to any account, please login to connect your #{params[:oauth][:provider]}. If you have no account, one will be created for you.",
            type: "error",
            title: "Almost there!"
        )
      elsif !@current_user.has_a_valid_authentication_method?
        set_flash_message(
            message: "Could not authenticate your account please look over your credentials. Maybe you don't have an account, why don't you create one?",
            type: "error",
            title: "Login error!"
        )
      end
      
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