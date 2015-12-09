class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.float :latitude
      t.float :longitude
      t.string :address
      t.index [:latitude, :longitude], unique: false
      t.references :customer, index: true
      t.timestamps null: false
    end
    add_foreign_key :locations, :customers
  end
end
