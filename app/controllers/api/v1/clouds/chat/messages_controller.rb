class Api::V1::Clouds::Chat::MessagesController < Api::V1Controller

  include ActionView::Helpers::AssetTagHelper
  def controller;self;end;private(:controller)

  # Fetches the 50 latest messages for a chat
  #
  # Examples
  # GET /v1/clouds/:cloud_id/chat/messages
  #
  # Returns a collection of messages
  def index

    @cloud = Cloud.lookup(params[:cloud_id])
    @messages = Message.where(topic: @cloud).order_by(created_at: :desc).limit(50).reverse

    render status: 200

  end

  # Creates a chat message and queues it to be broadcasted
  # in the current clouds Faye channel.
  #
  # content - The message content
  # client_id - An id of the client so the client can determine and filter messages sent by itself
  #
  # Examples
  # POST /v1/clouds/:cloud_id/chat/messages
  #
  # Returns the message that was sent.
  def create

    @cloud = Cloud.lookup(params[:cloud_id])

    @message = Message.new(params.for(Message).as(current_user).on(:create))
    @message.author = current_user
    @message.topic  = @cloud

    authorize @message, :create?

    # @message.urls.each do |url|
    #   begin
    #     @message.drops << @cloud.create_drop_deposit_from_url_by_user(url,current_user)
    #   end
    # end

    if @message.save
      render status: 200
    else
      build_errors_from_model @message
      render status: 422
    end

  end

end
