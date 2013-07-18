class CloudSerializer < ApplicationSerializer
  attribute :name, key: :display_name
  attributes :id, :avatar

  def avatar
    return object.dynamic_avatar_url(nil, :id, :https)
  end

end
