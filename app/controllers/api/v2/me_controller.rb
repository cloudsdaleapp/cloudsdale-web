# encoding: utf-8

class Api::V2::MeController < Api::V2Controller

  doorkeeper_for :show, :update, :get_auth_token, :if => ->{ current_user.new_record? }

  def show

    @user = current_resource_owner

    respond_with_resource(@user,
      status:      200,
      serializer:  MeSerializer,
      root:        :user
    )

  end

  def update

    @user = current_resource_owner

    authorize(@user,:update?)

    if @user.update_attributes(refine(@user,:update))
      respond_with_resource(@user,
        status:      200,
        serializer:  MeSerializer,
        root:        :user
      )
    else
      build_errors_from(@user)
      respond_with_resource(@user,
        status:      422,
        serializer:  MeSerializer,
        root:        :user
      )
    end

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
