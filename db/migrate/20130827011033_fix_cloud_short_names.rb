class FixCloudShortNames < Mongoid::Migration

  def self.up

    Cloud.nor(short_name: nil).nor(short_name: "").and(short_name: /\-/i).each do |cloud|
      cloud.short_name = cloud.short_name.gsub("-","_")
      cloud.save
    end

    Cloud.or(short_name: nil).or(short_name: "").each do |cloud|
      cloud.save
    end

  end

  def self.down
  end

end