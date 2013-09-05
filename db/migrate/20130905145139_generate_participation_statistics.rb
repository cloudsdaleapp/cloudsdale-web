class GenerateParticipationStatistics < Mongoid::Migration

  def self.up

    Cloud.all.each do |cloud|
      participants = Conversation.where(topic: cloud).count
      cloud.set(:participant_count, participants) if participants >= 1
    end

    User.all.each do |user|
      conversations = Conversation.where(user: user).count
      user.set(:conversation_count, conversations) if conversations >= 1
    end

  end

  def self.down
    User.all.unset(:conversation_count)
    Cloud.all.unset(:participant_count)
  end

end