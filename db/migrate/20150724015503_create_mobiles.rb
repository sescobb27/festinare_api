class CreateMobiles < ActiveRecord::Migration
  def change
    create_table :mobiles do |t|
      t.references :customer, index: true
      t.string :token, null: false
      t.boolean :enabled, default: true
      t.string :platform, null: false

      t.timestamps null: false
    end
    add_index :mobiles, :token
    add_index :mobiles, :platform
    add_foreign_key :mobiles, :customers
  end
end
