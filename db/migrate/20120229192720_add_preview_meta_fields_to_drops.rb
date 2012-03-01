class AddPreviewMetaFieldsToDrops < Mongoid::Migration
  def self.up
    Drop.where(:preview_dimensions => nil, :preview_file_type => nil).update_all(:preview_dimensions => { width: 0, height: 0}, :preview_file_type => "")
  end

  def self.down
    Drop.update_all(:preview_dimensions => nil, :preview_file_type => nil)
  end
end