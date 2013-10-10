class HandleSerializer < ActiveModel::Serializer

  cached # Make sure to cache the user object.

  attributes :id

  has_one :identifiable, embed: :ids, polymorphic: true

  def id
    object.id.downcase
  end

  # Public: The cache key for the HandleSerializer
  def cache_key
    "handles/#{object.id}-#{object.updated_at.utc.to_s(:number)}"
  end

end
