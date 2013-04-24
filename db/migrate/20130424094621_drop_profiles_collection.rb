class DropProfilesCollection < Mongoid::Migration

  def self.up
    Mongoid::Sessions.default[:profiles].drop
    puts "-> Dropped the 'profiles' collection"
  rescue
    puts "-> Could not drop the 'profiles' collection"
  end

  def self.down
    puts "-> This migration does not have a downstream"
  end

end
