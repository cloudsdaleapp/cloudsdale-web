class RenameGenderToGroupInPonies < ActiveRecord::Migration
  def change
    rename_column :ponies, :gender, :group
  end
end
