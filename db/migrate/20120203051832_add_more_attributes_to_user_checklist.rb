class AddMoreAttributesToUserChecklist < Mongoid::Migration
  
  def self.up
    User.where(:'checklist.read_recruiting_message'.ne => true).update_all(:'checklist.read_recruiting_message' => false)
  end

  def self.down
    User.update_all(:'checklist.read_recruiting_message' => nil)
  end
  
end