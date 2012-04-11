class RemoveSubscribersFromUsers < Mongoid::Migration
  
  def self.up
    User.all.each do |user|
      user.unset(:subscriber_ids)
      user.unset(:publisher_ids)
      user.save
    end
  end

  def self.down
    User.all.update_all(
      subscriber_ids: [],
      publisher_ids: []
    )
  end
  
end