class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.text :name

      t.timestamps
    end
    add_index :users, :name
  end
end