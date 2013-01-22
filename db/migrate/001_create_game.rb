class CreateGame < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :username, :null => false
      t.string :password, :null => false
      t.text :description
      t.integer :room
      t.integer :health

      t.timestamps
    
    end
      
    add_index :players, :username
    add_index :players, :room


    create_table :rooms do |t|
      t.integer :x, :null => false
      t.integer :y, :null => false
      t.integer :z, :null => false
      t.text :description

      t.timestamps
      
    end


    execute <<-SQL
      ALTER TABLE players ADD UNIQUE KEY(username)
    SQL
    execute <<-SQL
      ALTER TABLE rooms ADD UNIQUE KEY(x,y,z)
    SQL
  end
end

