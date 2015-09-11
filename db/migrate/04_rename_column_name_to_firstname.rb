class RenameColumnNameToFirstname < ActiveRecord::Migration
  def up
    rename_column :cats, :name, :firstname
  end
  
  def down
    rename_column :cats, :firstname, :name
  end
end
