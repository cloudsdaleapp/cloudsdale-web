class MeSerializer < UserSerializer

  cached # Make sure to cache the user object.

  attributes :read_terms, :default_avatar, :email, :email_verified

  # Public: Checks if user is using default avatar.
  # Returns true or false.
  def default_avatar
    not object.avatar.present?
  end

  # Public: Checks if user has read terms of agreements.
  # Returns true or false.
  def read_terms
    object.tnc_last_accepted.present?
  end

  # Public: Check if email is verified.
  # Returns true or false.
  def email_verified
    object.email_verified_at.present?
  end

  # Public: The cache key for the MeSerializer, this behaves a little
  # different than user serializers because it contains more data.
  def cache_key
    "me/#{object.id}-#{object.updated_at.utc.to_s(:number)}"
  end

  def refs
    [{ rel: 'self', href: v2_me_url(format: :json, host: $api_host) }]
  end

end
