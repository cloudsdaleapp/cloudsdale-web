# encoding: utf-8

class Api::V2::MeController < Api::V2Controller

  doorkeeper_for :show, :auth_token

  def show
    respond_with current_resource_owner, status: 200, serializer: MeSerializer, root: 'user', meta: {
      status: 200
    }
  end

  def auth_token
    resp = {
      user: {
        auth_token: current_resource_owner.auth_token,
      },
      meta: {
        status: 200,
        errors: [
          {
            error_type: "warning",
            error_message: "This resource is deprecated.",
            error_code: "DEPRECATION_WARNING"
          }
        ]
      }
    }
    respond_with resp, status: 200
  end

end
