class Api::V2Controller < ActionController::Base

  include Pundit

  respond_to :json, :xml

end
