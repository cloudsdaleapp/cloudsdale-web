class UserSerializer < ApplicationSerializer

  cached true

  attribute :name,          key: :display_name
  attribute :symbolic_role, key: :role_name

  attributes :username, :role, :avatar, :suspended

  attribute :refs

  def avatar
    avatar_id_type = object.email_hash.present? ? :email_hash : :id
    return object.dynamic_avatar_url(nil, avatar_id_type, :https)
  end

  def suspended
    object.banned?
  end

  def cache_key
    [object.id, object.updated_at.utc.to_s(:number)].join("-")
  end

  def refs
    [{ rel: 'self', href: v2_user_url(object.id, format: :json, host: $api_host) }]
  end

end
