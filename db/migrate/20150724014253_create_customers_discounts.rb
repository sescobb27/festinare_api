class CreateCustomersDiscounts < ActiveRecord::Migration
  def change
    create_table :customers_discounts do |t|
      t.references :customer, index: true
      t.references :discount, index: true
      t.timestamps null: false
      t.integer :rate
      t.string :feedback, limit: 140
      t.index [:customer_id, :discount_id], unique: true
      t.index [:discount_id, :customer_id], unique: true
    end
    add_foreign_key :customers_discounts, :customers
    add_foreign_key :customers_discounts, :discounts
  end
end
