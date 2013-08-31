class SpotlightSerializer < ApplicationSerializer

  embed :ids, include: true

  attributes :text, :category

  has_one :target, polymorphic: true, flatten: true

  attribute :refs

  def cache_key
    [object.id, object.updated_at.utc.to_s(:number)].join("-")
  end

  def refs
    [{ rel: 'self', href: v2_spotlight_url(object.id, format: :json, host: $api_host) }]
  end

end
