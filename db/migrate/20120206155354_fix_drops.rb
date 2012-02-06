class FixDrops < Mongoid::Migration
  
  def self.up
    puts "Removing old drops..."
    Drop.any_in(strategy: ['cloudsdale_users','cloudsdale_clouds']).destroy_all
    puts "Rebuilding tire index..."
    Tire.index('drops').create
    Tire.index('drops').refresh
    puts "Importing the index..."
    Drop.tire.import
    puts "Saving all clouds and users to build new drops..."
    Cloud.all.each{|c|c.save}
    User.all.each{|c|c.save}
    puts "Refreshing index for all cloudsdale users"
    Drop.any_in(strategy: ['cloudsdale_users','cloudsdale_clouds']).each{|d|d.update_index}
  end

  def self.down
  end
  
end