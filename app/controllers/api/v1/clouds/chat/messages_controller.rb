class Api::V1::Clouds::Chat::MessagesController < Api::V1Controller

  include ActionView::Helpers::AssetTagHelper
  def controller;self;end;private(:controller)

  before_filter do
    @cloud = fetch_cloud(params[:cloud_id])
  end

  # Fetches the 50 latest messages for a chat
  #
  # Examples
  # GET /v1/clouds/:cloud_id/chat/messages
  #
  # Returns a collection of messages
  def index

    @messages = @cloud.chat.messages.order_by([:timestamp,:desc]).limit(50).reverse

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

    # Autoprune - Fetches all the oldest messages and TRASHES THEM LIKE A BAWS!
    # TODO: MAEK BUAUTIFULIER!
    @cloud.chat.messages.old.each { |message| message.destroy } if @cloud.chat.messages.count > 50

    @message = @cloud.chat.messages.build params[:message]
    @message.author = current_user

    authorize @message, :create?

    @message.urls.each do |url|
      @message.drops << @cloud.create_drop_deposit_from_url_by_user(url,current_user)
    end

    if @message.save
      render status: 200
    else
      build_errors_from_model @message
      render status: 422
    end

  end

private

  # Private: Fetch cloud unscoped to include all chat messages.
  #
  # id - The ID of the Cloud to fetch.
  #
  # Examples
  #
  # fetch_cloud("...")
  # # => <Cloud ...>
  #
  # Returns the user if a user is present
  def fetch_cloud(id)
    @cloud ||= Cloud.unscoped.find(id)
  end

end
