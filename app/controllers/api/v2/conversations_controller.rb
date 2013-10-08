# encoding: utf-8

class Api::V2::ConversationsController < Api::V2Controller

  doorkeeper_for :show, :if => ->{ current_user.new_record? }

  def show
    @topic = Handle.lookup(params.require(:topic))
    @convo = Conversation.where(user_id: current_resource_owner.id, topic_id: @topic.id).first
    @convo ||= Conversation.request(user: current_resource_owner, topic: @topic)

    authorize(@convo, :show?)

    respond_with_resource(@convo, serializer: ConversationSerializer, root: :conversation)
  end

  def update
    @topic = Handle.lookup(params.require(:topic))
    @convo = Conversation.where(user_id: current_resource_owner.id, topic_id: @topic.id).first
    # @convo ||= Conversation.request(user: current_resource_owner, topic: @topic)

    authorize(@convo, :update?)

    respond_with_resource(@convo, serializer: ConversationSerializer, root: :conversation)
  end

end