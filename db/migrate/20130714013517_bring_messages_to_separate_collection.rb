class BringMessagesToSeparateCollection < Mongoid::Migration

  def self.up

    # @messages = []

    # puts "==  BringMessagesToSeparateCollection: counting messages ======================"
    # Mongoid::Sessions.default['clouds'].find.each do |c|
    #   c["chat"]["messages"].each do |m|
    #     message            = Message.new
    #     message[:_id]      = m["_id"]
    #     message.topic_id   = c["_id"]
    #     message.topic_type = "Cloud"
    #     message.author_id  = m["author_id"]
    #     message.device     = m["device"]
    #     message.content    = m["content"]
    #     message.created_at = m["created_at"]
    #     message.updated_at = m["updated_at"]

    #     # Deprecated but migrated anyway
    #     message.drop_ids   = m["drop_ids"]
    #     message.urls       = m["urls"]
    #     message.timestamp  = m["timestamp"]

    #     @messages << message.as_document
    #   end
    # end
    # puts "==  BringMessagesToSeparateCollection: done listing (#{@messages.size}) messages ======"
    # puts "==  BringMessagesToSeparateCollection: inserting messages ====================="
    # @messages.each_slice(1000).to_a.each do |grouped_messages|
    #   Message.collection.insert(grouped_messages)
    #   puts "==  BringMessagesToSeparateCollection: inserted #{grouped_messages.size} messages ================="
    # end
    # puts "==  BringMessagesToSeparateCollection: done inserting all ====================="

  end

  def self.down
    Mongoid::Sessions.default['messages'].drop
  end
end