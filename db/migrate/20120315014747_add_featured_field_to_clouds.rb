class AddFeaturedFieldToClouds < Mongoid::Migration
  def self.up
    Cloud.where(:featured.ne => true).update_all(featured: false)
  end

  def self.down
    Cloud.update_all(featured: nil)
  end
end