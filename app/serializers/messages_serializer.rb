class MessagesSerializer < ActiveModel::ArraySerializer

  cached true

  def cache_key
    expand_cache_key(children_cache_keys)
  end

  def children_cache_keys
    object.map{ |object| [object.id, object.updated_at.utc.to_s(:number)].join("-") }
  end

end
