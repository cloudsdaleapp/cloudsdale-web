class AddChecklistDocumentToUsers < Mongoid::Migration
  
  def self.up
    
    # Creates a checklist for all users that does not have one.
    User.all.each do |user|
      unless user.checklist.is_a?(Checklist)
        user.create_checklist if user.valid?
        user.save
      end
    end
    
  end
  
end