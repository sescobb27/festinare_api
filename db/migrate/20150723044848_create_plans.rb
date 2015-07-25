class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name, null: false, limit: 40
      t.text :description, limit: 120
      t.integer :price, null: false
      t.integer :num_of_discounts, null: false
      t.string :currency, null: false
      t.integer :expired_rate, null: false
      t.string :expired_time, null: false
      t.datetime :deleted_at
      t.timestamps null: false
    end
    add_index :plans, :name, unique: true
    add_index :plans, :deleted_at
  end
end
