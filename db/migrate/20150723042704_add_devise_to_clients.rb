class AddDeviseToClients < ActiveRecord::Migration
  def change
    change_table(:clients) do |t|
      ## Database authenticatable
      t.string :email,              null: false, limit: 100
      t.string :encrypted_password, null: false

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
    end
    add_index :clients, :email,                unique: true
    add_index :clients, :reset_password_token, unique: true
    add_index :clients, :confirmation_token,   unique: true
  end
end
