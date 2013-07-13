class PutConversationsInTheirOwnCollection < Mongoid::Migration

  def self.up
    User.all.unset(:conversations)
    User.all.includes(:clouds).each do |user|
      user.clouds.each { |cloud| c = Conversation.as(user, about: cloud); c.start if c.new_record? }
      print '.'
    end
    puts "\n"
  end

  def self.down
    Mongoid::Sessions.default['conversations'].drop
  end

end