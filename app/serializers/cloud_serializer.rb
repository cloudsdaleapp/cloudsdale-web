class CloudSerializer < ApplicationSerializer

  attribute :name, key: :display_name

  attributes :short_name, :avatar

  attributes :hidden, :locked

  attribute :refs

  def avatar
    return object.dynamic_avatar_url(nil, :id, :https)
  end

  def refs
    { rel: 'self', href: v2_cloud_url(object.to_param.downcase, format: :json, host: $api_host) }
  end

end
