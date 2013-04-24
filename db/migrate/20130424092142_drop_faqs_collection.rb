class DropFaqsCollection < Mongoid::Migration

  def self.up
    Mongoid::Sessions.default[:faqs].drop
    puts "-> Dropped the 'faqs' collection"
  rescue
    puts "-> Could not drop the 'faqs' collection"
  end

  def self.down
    puts "-> This migration does not have a downstream"
  end

end
