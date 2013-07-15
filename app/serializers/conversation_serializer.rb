class ConversationSerializer < ApplicationSerializer
  embed :ids,   include: true

  attributes :position, :access

  has_one :topic, polymorphic: true

end
