class HandleSerializer < ActiveModel::Serializer

  cached # Make sure to cache the user object.

  attributes :id

  has_one :identifiable, embed: :ids, polymorphic: true

  # Public: The cache key for the HandleSerializer
  def cache_key
    "handle/#{object.id}"
  end

end
