class CreateClientsPlans < ActiveRecord::Migration
  def change
    create_table :clients_plans do |t|
      t.references :client, index: true
      t.references :plan, index: true
      t.index [:client_id, :plan_id]
      t.integer :num_of_discounts_left, null: false
      t.boolean :status, default: true
      t.datetime :expired_date, null: false
      t.datetime :created_at, null: false
    end
    add_foreign_key :clients_plans, :clients
    add_foreign_key :clients_plans, :plans
  end
end
