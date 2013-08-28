# encoding: utf-8

class Api::V2::ConversationsController < Api::V2Controller

  doorkeeper_for :show, :if => ->{ current_user.new_record? }

  def show
    @topic = Handle.lookup(params[:id])
    @convo = Conversation.find_by(user_id: current_resource_owner.id, topic_id: @topic.id)

    authorize(@convo,:show?)

    respond_with_resource(@convo, serializer: ConversationSerializer, root: :conversation)

  rescue Mongoid::Errors::DocumentNotFound
    raise Mongoid::Errors::DocumentNotFound.new(Conversation,params[:id],params[:id])
  end

end