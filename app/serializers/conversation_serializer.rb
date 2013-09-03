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
    refs << { rel: 'self', href: v2_me_conversation_url(handle, format: :json, host: $api_host) } if handle.present?
  end

  def socket
    {
      channel: object.channel_name
    }
  end

end
