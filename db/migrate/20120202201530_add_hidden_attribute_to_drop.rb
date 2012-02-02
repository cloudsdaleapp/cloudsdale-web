class AddHiddenAttributeToDrop < Mongoid::Migration
  
  def self.up
    Drop.where(:hidden.ne => "true").update_all(hidden: "false")
  end

  def self.down
    Drop.all.update_all(hidden: nil)
  end
  
end