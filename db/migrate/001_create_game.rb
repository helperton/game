class CreateGame < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name, :null => false
      t.string :password, :null => false
      t.text :description, :null => false
      t.integer :room, :null => false
      t.integer :health, :null => false
      t.timestamps
    
    end
      
    add_index :players, :name
    add_index :players, :room


    create_table :rooms do |t|
      t.integer :x, :null => false
      t.integer :y, :null => false
      t.integer :z, :null => false
      t.timestamps
      
    end


    execute <<-SQL
      ALTER TABLE players ADD UNIQUE KEY(name)
    SQL
    execute <<-SQL
      ALTER TABLE rooms ADD UNIQUE KEY(x,y,z)
    SQL
  end
end

