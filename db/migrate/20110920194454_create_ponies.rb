class CreatePonies < ActiveRecord::Migration
  def change
    create_table :ponies do |t|
      t.integer :user_id
      t.string :name
      t.string :gender
      t.integer :type
    end
  end
end
