class SetRecordTypeForConversation < Mongoid::Migration

  def self.up
    Conversation.all.set(:_type,"Conversation") if defined? Conversation
  end

  def self.down
    Conversation.all.set(:_type) if defined? Conversation
  end

end