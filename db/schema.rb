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

ActiveRecord::Schema.define(version: 20150809121148) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "address_infos", force: :cascade do |t|
    t.string   "type"
    t.string   "city",                       null: false
    t.string   "street",                     null: false
    t.string   "state",            limit: 2, null: false
    t.integer  "user_id"
    t.integer  "home_number"
    t.integer  "apartment_number"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "bids", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "commodity_id"
    t.decimal  "price",        precision: 10, scale: 2
    t.inet     "ip"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "bids", ["commodity_id"], name: "index_bids_on_commodity_id", using: :btree
  add_index "bids", ["user_id"], name: "index_bids_on_user_id", using: :btree

  create_table "commodities", force: :cascade do |t|
    t.string   "description"
    t.string   "picture"
    t.decimal  "weight",         precision: 10, scale: 2, default: 0.0
    t.decimal  "dim_w",          precision: 10, scale: 2, default: 0.0
    t.decimal  "dim_h",          precision: 10, scale: 2, default: 0.0
    t.decimal  "dim_l",          precision: 10, scale: 2, default: 0.0
    t.integer  "distance",                                                null: false
    t.integer  "user_id"
    t.integer  "truckload_type"
    t.boolean  "hazard",                                  default: false
    t.boolean  "active",                                  default: true
    t.decimal  "price",          precision: 10, scale: 2
    t.datetime "pickup_at",                                               null: false
    t.datetime "arrive_at",                                               null: false
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  add_index "commodities", ["truckload_type"], name: "index_commodities_on_truckload_type", using: :btree
  add_index "commodities", ["user_id"], name: "index_commodities_on_user_id", using: :btree

  create_table "commodity_feedbacks", force: :cascade do |t|
    t.string   "description"
    t.integer  "rate",         null: false
    t.integer  "user_id"
    t.integer  "commodity_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "commodity_feedbacks", ["commodity_id"], name: "index_commodity_feedbacks_on_commodity_id", using: :btree
  add_index "commodity_feedbacks", ["user_id"], name: "index_commodity_feedbacks_on_user_id", using: :btree

  create_table "identities", force: :cascade do |t|
    t.string   "uid"
    t.string   "provider"
    t.string   "token"
    t.string   "secret"
    t.string   "email"
    t.string   "avatar_url"
    t.string   "nickname"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "identities", ["uid", "provider"], name: "index_identities_on_uid_and_provider", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "about"
    t.string   "avatar"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "blocked",                default: false,   null: false
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.json     "tokens"
  end

  add_index "users", ["blocked"], name: "index_users_on_blocked", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
