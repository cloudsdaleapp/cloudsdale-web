class MeSerializer < UserSerializer

  attributes :read_terms, :default_avatar, :email, :email_verified

  def default_avatar
    not object.avatar.present?
  end

  def read_terms
    object.tnc_last_accepted.present?
  end

  def email_verified
    object.email_verified_at.present?
  end

end
