class MessageSerializer < ApplicationSerializer

  cached true

  embed :ids, include: true

  has_one :author, polymorphic: true
  has_one :topic,  polymorphic: true, include: false

  attributes :content, :device, :client_id

  def type
    super.present? ? super : "message"
  end

  def cache_key
    [object.id, object.updated_at.utc.to_s(:number)].join("-")
  end

private

  def include_author?
    object.author.present?
  end

  def include_client_id?
    object.client_id.present?
  end

end