extends 'api/v1/messages/mini'

object @message

node(:topic) { |message| { type: message.topic_type, id: message.topic_id } }