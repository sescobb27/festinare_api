# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151102025219) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string   "name",                   limit: 120,              null: false
    t.string   "categories",                         default: [],              array: true
    t.string   "tokens",                             default: [],              array: true
    t.string   "username",               limit: 100
    t.string   "image_url"
    t.string   "addresses",                          default: [],              array: true
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "email",                  limit: 100,              null: false
    t.string   "encrypted_password",                              null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
  end

  add_index "clients", ["confirmation_token"], name: "index_clients_on_confirmation_token", unique: true, using: :btree
  add_index "clients", ["email"], name: "index_clients_on_email", unique: true, using: :btree
  add_index "clients", ["name"], name: "index_clients_on_name", unique: true, using: :btree
  add_index "clients", ["reset_password_token"], name: "index_clients_on_reset_password_token", unique: true, using: :btree
  add_index "clients", ["tokens"], name: "index_clients_on_tokens", using: :gin
  add_index "clients", ["username"], name: "index_clients_on_username", unique: true, using: :btree

  create_table "clients_plans", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "plan_id"
    t.integer  "num_of_discounts_left",                null: false
    t.boolean  "status",                default: true
    t.datetime "expired_date",                         null: false
    t.datetime "created_at",                           null: false
  end

  add_index "clients_plans", ["client_id", "plan_id"], name: "index_clients_plans_on_client_id_and_plan_id", using: :btree
  add_index "clients_plans", ["client_id"], name: "index_clients_plans_on_client_id", using: :btree
  add_index "clients_plans", ["plan_id"], name: "index_clients_plans_on_plan_id", using: :btree

  create_table "customers", force: :cascade do |t|
    t.string   "fullname",               limit: 100,              null: false
    t.string   "categories",                         default: [],              array: true
    t.string   "tokens",                             default: [],              array: true
    t.string   "username",               limit: 100
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "email",                  limit: 100,              null: false
    t.string   "encrypted_password",                              null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
  end

  add_index "customers", ["confirmation_token"], name: "index_customers_on_confirmation_token", unique: true, using: :btree
  add_index "customers", ["email"], name: "index_customers_on_email", unique: true, using: :btree
  add_index "customers", ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true, using: :btree
  add_index "customers", ["tokens"], name: "index_customers_on_tokens", using: :gin
  add_index "customers", ["username"], name: "index_customers_on_username", unique: true, using: :btree

  create_table "customers_discounts", force: :cascade do |t|
    t.integer  "customer_id"
    t.integer  "discount_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "rate"
    t.string   "feedback",    limit: 140
    t.boolean  "redeemed",                default: false
  end

  add_index "customers_discounts", ["customer_id", "discount_id"], name: "index_customers_discounts_on_customer_id_and_discount_id", unique: true, using: :btree
  add_index "customers_discounts", ["customer_id"], name: "index_customers_discounts_on_customer_id", using: :btree
  add_index "customers_discounts", ["discount_id", "customer_id"], name: "index_customers_discounts_on_discount_id_and_customer_id", unique: true, using: :btree
  add_index "customers_discounts", ["discount_id"], name: "index_customers_discounts_on_discount_id", using: :btree

  create_table "discounts", force: :cascade do |t|
    t.integer  "discount_rate",                                 null: false
    t.string   "title",         limit: 100,                     null: false
    t.string   "secret_key",                                    null: false
    t.boolean  "status",                    default: true
    t.integer  "duration",                                      null: false
    t.string   "duration_term",             default: "minutes"
    t.string   "hashtags",                  default: [],                     array: true
    t.integer  "client_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "discounts", ["client_id"], name: "index_discounts_on_client_id", using: :btree
  add_index "discounts", ["hashtags"], name: "index_discounts_on_hashtags", using: :gin

  create_table "locations", force: :cascade do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.string   "address"
    t.integer  "customer_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "locations", ["customer_id"], name: "index_locations_on_customer_id", using: :btree
  add_index "locations", ["latitude", "longitude"], name: "index_locations_on_latitude_and_longitude", using: :btree

  create_table "mobiles", force: :cascade do |t|
    t.integer  "customer_id"
    t.string   "token",                      null: false
    t.boolean  "enabled",     default: true
    t.string   "platform",                   null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "mobiles", ["customer_id"], name: "index_mobiles_on_customer_id", using: :btree
  add_index "mobiles", ["platform"], name: "index_mobiles_on_platform", using: :btree
  add_index "mobiles", ["token"], name: "index_mobiles_on_token", using: :btree

  create_table "plans", force: :cascade do |t|
    t.string   "name",             limit: 40, null: false
    t.text     "description"
    t.integer  "price",                       null: false
    t.integer  "num_of_discounts",            null: false
    t.string   "currency",                    null: false
    t.integer  "expired_rate",                null: false
    t.string   "expired_time",                null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "plans", ["deleted_at"], name: "index_plans_on_deleted_at", using: :btree
  add_index "plans", ["name"], name: "index_plans_on_name", unique: true, using: :btree

  add_foreign_key "clients_plans", "clients"
  add_foreign_key "clients_plans", "plans"
  add_foreign_key "customers_discounts", "customers"
  add_foreign_key "customers_discounts", "discounts"
  add_foreign_key "discounts", "clients"
  add_foreign_key "locations", "customers"
  add_foreign_key "mobiles", "customers"
end
