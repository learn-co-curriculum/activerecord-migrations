class CreateAnimals < ActiveRecord::Migration
  def up
    create_table :animals do |t|
      t.string :name
      t.integer :age
      t.integer :breed
    end
  end

  def down
    drop_table :animals
  end
end
