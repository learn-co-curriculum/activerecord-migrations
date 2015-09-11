class AddColumnToCats < ActiveRecord::Migration
  def up
    add_column :cats, :owner_id, :integer
  end
  
  def down
    remove_foreign_key :cats, :owner_id
  end
end
