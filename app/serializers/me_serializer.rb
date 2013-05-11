class MeSerializer < UserSerializer

  attributes :total_clouds, :read_terms, :using_default_avatar, :notifications

  def total_clouds
    object.cloud_ids.try(:size) || 0
  end

  def using_default_avatar
    not object.avatar.present?
  end

  def read_terms
    object.tnc_last_accepted.present?
  end

  def notifications
    0
  end

end
