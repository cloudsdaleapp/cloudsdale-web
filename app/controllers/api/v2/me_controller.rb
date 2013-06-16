# encoding: utf-8

class Api::V2::MeController < Api::V2Controller

  doorkeeper_for :show, :backport

  def show
    respond_with current_resource_owner, status: 200, serializer: MeSerializer, root: 'user', meta: {
      status: 200
    }
  end

  def auth_token
    resp = {
      auth_token: current_resource_owner.auth_token,
      meta: {
        status: 200,
        errors: [],
        notice: "Access to auth tokens is deprecated."
      }
    }
    respond_with resp, status: 200
  end

private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

end
