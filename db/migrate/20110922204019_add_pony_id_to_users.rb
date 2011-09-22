class AddPonyIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pony_id, :integer
  end
end
