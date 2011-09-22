class AddAttributesToPonies < ActiveRecord::Migration
  def change
    add_column :ponies, :color_coat, :string
    add_column :ponies, :color_mane, :string
    add_column :ponies, :color_eyes, :string
    add_column :ponies, :avatar, :string
  end
end
