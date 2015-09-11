class AddGenderToCats < ActiveRecord::Migration
  def up
    add_column :cats, :gender, :string
  end
  
  def down
    remove_column :cats, :gender 
  end
end
