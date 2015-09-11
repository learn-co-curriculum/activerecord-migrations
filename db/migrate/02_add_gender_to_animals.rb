class AddGenderToAnimals < ActiveRecord::Migration
  def up
    add_column :animals, :gender, :string
  end
  
  def down
    remove_column :animals, :gender 
  end
end
