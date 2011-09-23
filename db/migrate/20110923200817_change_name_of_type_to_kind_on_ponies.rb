class ChangeNameOfTypeToKindOnPonies < ActiveRecord::Migration
    rename_column :ponies, :type, :kind
end