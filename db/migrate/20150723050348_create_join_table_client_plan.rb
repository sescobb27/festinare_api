class CreateJoinTableClientPlan < ActiveRecord::Migration
  def change
    create_join_table :clients, :plans do |t|
      t.index :client_id
      t.index :plan_id
      t.index [:client_id, :plan_id]
      t.integer :num_of_discounts_left, null: false
      t.datetime :expired_date, null: false
      t.datetime :created_at, null: false
    end
  end
end
