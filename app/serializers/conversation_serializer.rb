class ConversationSerializer < ApplicationSerializer
  embed :ids, include: true

  attributes :position, :access, :handle

  has_one :topic, polymorphic: true, flatten: true

  def handle
    case object.topic.class
    when User then object.topic.username.downcase
    when Cloud then object.topic.short_name.downcase
    end
  end

end
