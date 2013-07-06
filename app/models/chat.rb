class Chat

  include Mongoid::Document

  embedded_in :topic,     polymorphic: true,   :validate => false
  embeds_many :messages,  :validate => false

  field :token,         type: String

  # Public: Fetches the time for when the last message
  # was sent over this chat
  #
  # Returns a DateTime object.
  def last_message_at
    messages.order_by([:timestamp,:desc]).limit(1).first.try(:timestamp)
  end

end
