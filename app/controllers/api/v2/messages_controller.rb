class Api::V2::MessagesController < Api::V2Controller

  def index

    @before   = params[:before].present? ? Time.at(params[:before].to_i) : Time.now
    @limit    = params[:limit].try(:to_i) || 50

    @topic    = get_topic
    @convo    = Conversation.find_by(user: current_user, topic: @topic)

    @messages = @convo.messages(before: @before, limit: @limit)

    meta = {}
    if not @messages.empty?

      @before = @messages.to_a.last.created_at.utc.to_i

      unless @messages.to_a.count < @limit
        meta[:refs] = []
        meta[:refs] << {
          rel: 'more',
          href: v2_convo_messages_url(
            format: :json,
            host:   $api_host,
            topic:  @topic,
            before: @before,
            limit:  @limit
          )
        }
        meta[:more] = {
          topic:  @topic.to_param,
          before: @before,
          limit:  @limit
        }
      end
    end

    respond_with(@messages, serializer: MessagesSerializer, meta: meta, meta_key: :collection)
  rescue Mongoid::Errors::DocumentNotFound
    render_exception("Sorry, could not find messages for that #{Conversation}.", 404)
  end

  def create
    @topic    = get_topic
    @convo    = Conversation.find_by(user: current_user, topic: @topic)

    @message = Message.refined_build(params, convo: @convo)

    authorize(@message, :create?)

    if @message.save
      respond_with_resource(@message, serializer: MessageSerializer)
    else
      build_errors_from(@message)
      respond_with_resource(@message, serializer: MessageSerializer)
    end
  end

  def destroy
    @message = Message.find(params[:id])

    authorize(@message, :destroy?)

    if @message.destroy
      respond_with_resource(@message, serializer: MessageSerializer)
    else
      build_errors_from(@message)
      respond_with_resource(@message, serializer: MessageSerializer)
    end
  end

  def update
    @message = Message.find(params[:id])

    authorize(@message, :update?)

    if @message.refined_update(params, editor: current_user)
      respond_with_resource(@message, serializer: MessageSerializer)
    else
      build_errors_from(@message)
      respond_with_resource(@message, serializer: MessageSerializer)
    end
  end

private

  def get_topic
    if params[:topic_id] && params[:topic_type]
      case params[:topic_type]
        when 'cloud' then Handle.lookup(params[:topic_id], kind: Cloud)
        when 'user'  then Handle.lookup(params[:topic_id], kind: User)
        else Handle.lookup(params[:topic_id])
      end
    else
      Handle.lookup(params.require(:convo_id))
    end
  end

end