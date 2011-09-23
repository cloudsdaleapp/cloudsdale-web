class ChangeDatatypesOnPonies < ActiveRecord::Migration
  def change
    change_column :ponies, :type, :string
  end
end