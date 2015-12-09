class AddRedeemedToCustomersDiscounts < ActiveRecord::Migration
  def change
    add_column :customers_discounts, :redeemed, :boolean, default: false
  end
end
