class CreateHandlesForAllUsers < Mongoid::Migration
  def self.up
    User.all.each do |user|
      user.save
    end
  end

  def self.down
    Handle.destroy_all
  end
end