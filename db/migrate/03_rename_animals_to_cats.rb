class RenameAnimalsToCats < ActiveRecord::Migration
  def up
    rename_table :animals, :cats
  end
  
  def down
    rename_table :cats, :animals
  end
end
