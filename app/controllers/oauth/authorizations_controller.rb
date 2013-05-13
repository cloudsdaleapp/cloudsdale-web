class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController

  include ActionController::FrontAuth
  layout 'auth'

end
