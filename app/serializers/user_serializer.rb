class UserSerializer < ApplicationSerializer

  attribute :name,          key: :display_name
  attribute :symbolic_role, key: :role_name

  attributes :username, :role, :avatar, :suspended

  def avatar
    avatar_id_type = object.email_hash.present? ? :email_hash : :id
    return object.dynamic_avatar_url(nil, avatar_id_type, :https)
  end

  def suspended
    object.banned?
  end

end
