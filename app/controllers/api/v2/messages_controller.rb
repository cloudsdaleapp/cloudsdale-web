class Api::V2::MessagesController < Api::V2Controller

  def index

    @before   = params[:before].present? ? Time.at(params[:before].to_i) : Time.now
    @limit    = params[:limit].try(:to_i) || 50

    @topic    = Handle.lookup(params.require(:topic))
    @convo    = Conversation.find_by(user: current_user, topic: @topic)

    @messages = @convo.messages(before: @before, limit: @limit)

    meta = {}
    if not @messages.empty?
      meta[:refs] = []
      meta[:refs] << {
        rel: 'more',
        href: v2_messages_url(
          format: :json,
          host:   $api_host,
          topic:  @topic,
          before: @messages.to_a.last.created_at.utc.to_i,
          limit:  @limit
        )
      } unless @messages.to_a.count < @limit
    end

    respond_with(@messages, serializer: MessagesSerializer, meta: meta, meta_key: :collection)
  rescue Mongoid::Errors::DocumentNotFound
    render_exception("Sorry, could not find messages for that #{Conversation}.", 404)
  end

end