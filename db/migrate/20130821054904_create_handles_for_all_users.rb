class CreateHandlesForAllUsers < Mongoid::Migration
  def self.up
    User.all.each do |user|
      unless user.save
        user.generate_identity && user.save
      end
    end
  end

  def self.down
    Handle.destroy_all
  end
end