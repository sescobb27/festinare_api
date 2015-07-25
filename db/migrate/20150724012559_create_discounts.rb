class CreateDiscounts < ActiveRecord::Migration
  def change
    create_table :discounts do |t|
      t.integer :discount_rate, null: false
      t.string :title, null: false, limit: 100
      t.boolean :status, default: true
      t.integer :duration, null: false
      t.string :duration_term, default: 'minutes'
      t.string :hashtags, array: true, default: []
      t.references :client, index: true
      t.timestamps null: false
    end
    add_index :discounts, :hashtags, using: 'gin'
    add_foreign_key :discounts, :clients
  end
end
