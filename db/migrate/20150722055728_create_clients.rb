class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name, null: false, limit: 120
      t.string :categories, array: true, default: []
      t.string :tokens, array: true, default: []
      t.string :username, limit: 100
      t.string :image_url
      t.string :addresses, array: true, default: []
      t.timestamps null: false
    end
    add_index :clients, :name, unique: true
    add_index :clients, :username, unique: true
    add_index :clients, :tokens, using: 'gin'
  end
end
