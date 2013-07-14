class PutConversationsInTheirOwnCollection < Mongoid::Migration

  def self.up
    # User.all.unset(:conversations)
    # User.all.includes(:clouds,:conversations).each do |user|
    #   user.clouds.each do |cloud|
    #     c = Conversation.as(user, about: cloud)
    #     if c.new_record?
    #       c.start
    #       print "."
    #     end
    # end
  end

  def self.down
    Mongoid::Sessions.default['conversations'].drop
  end

end