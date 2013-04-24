class UnsetCharacterOnUsers < Mongoid::Migration
  def self.up
    User.where(:character.ne => nil).each do |user|
      user.unset(:character)
    end
    puts "-> Removed 'character' from all users"
  end

  def self.down
    puts "-> This migration does not have a downstream"
  end
end
