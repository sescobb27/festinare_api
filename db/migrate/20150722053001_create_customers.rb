class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :fullname, null: false, limit: 100
      t.string :categories, array: true, default: []
      t.string :tokens, array: true, default: []
      t.string :username, limit: 100
      t.timestamps null: false
    end
    add_index :customers, :username, unique: true
    add_index :customers, :tokens, using: 'gin'
  end
end
