# encoding: utf-8

class Api::V2::ConversationsController < Api::V2Controller

  doorkeeper_for :show, :if => ->{ current_user.new_record? }

  def create
    @convo = Conversation.refined_build(params, user: current_resource_owner)

    authorize(@convo, :create?)

    if @convo.start
      respond_with_resource(@convo, serializer: ConversationSerializer, root: :conversation)
    else
      build_errors_from(@convo)
      respond_with_errors status: 422
    end
  end

  def update
    @convo = Conversation.find(params[:id])

    authorize(@convo, :update?)

    @convo.start if @convo.new_record?

    respond_with_resource(@convo, serializer: ConversationSerializer, root: :conversation)
  end

  def destroy
    @convo = Conversation.find(params[:id])

    authorize(@convo, :destroy?)

    @convo.stop

    render nothing: true, status: 204
  end

  def lookup
    @topic = Handle.lookup(params.require(:topic))
    @convo = Conversation.where(user_id: current_resource_owner.id, topic_id: @topic.id).first
    @convo ||= Conversation.request(user: current_resource_owner, topic: @topic)

    authorize(@convo, :show?)

    respond_with_resource(@convo, serializer: ConversationSerializer, root: :conversation)
  end

end