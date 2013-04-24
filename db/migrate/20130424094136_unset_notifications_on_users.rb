class UnsetNotificationsOnUsers < Mongoid::Migration
  def self.up
    User.where(:notifications.ne => nil).each do |user|
      user.unset(:notifications)
    end
    puts "-> Removed 'notifications' from all users"
  end

  def self.down
    puts "-> This migration does not have a downstream"
  end
end
