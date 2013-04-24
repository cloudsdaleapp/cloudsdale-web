class UnsetChecklistOnUsers < Mongoid::Migration
  def self.up
    User.where(:checklist.ne => nil).each do |user|
      user.unset(:checklist)
    end
    puts "-> Removed 'checklist' from all users"
  end

  def self.down
    puts "-> This migration does not have a downstream"
  end
end
