class ConversationSerializer < ApplicationSerializer

  embed :ids, include: true

  attributes :position, :access, :handle, :refs, :socket

  has_one :user,  polymorphic: true
  has_one :topic, polymorphic: true

  def handle
    case object.topic.class
    when User then object.topic.username.downcase
    when Cloud then object.topic.short_name.downcase
    end
  end

  def refs
    refs ||= []
    if handle.present?
      refs << { rel: 'self',     href: v2_convo_url(handle, format: :json, host: $api_host) }
      refs << { rel: 'messages', href: v2_convo_messages_url(handle, format: :json, host: $api_host) }
    end
  end

  def socket
    {
      channel: object.channel_name
    }
  end

end
