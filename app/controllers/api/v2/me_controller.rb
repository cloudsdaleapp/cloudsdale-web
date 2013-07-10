# encoding: utf-8

class Api::V2::MeController < Api::V2Controller

  doorkeeper_for :show, :get_auth_token, :if => ->{ current_user.new_record? }

  def show

    respond_with_resource(current_resource_owner,
      status:      200,
      serializer:  UserSerializer,
      root:        :user
    )

  end

  def get_auth_token

    add_error(
      type:    :warning,
      message: "This resource is deprecated."
    )

    respond_with_resource(current_resource_owner,
      status: 200,
      serializer: Me::AuthTokenSerializer,
      root: :user
    )

  end

end
