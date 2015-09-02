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

ActiveRecord::Schema.define(version: 20150901120503) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "address_infos", force: :cascade do |t|
    t.string   "type"
    t.string   "contact_name",                           null: false
    t.string   "city",                                   null: false
    t.string   "zip_code",                               null: false
    t.string   "address1",                               null: false
    t.string   "state",        limit: 2,                 null: false
    t.boolean  "appointment",            default: false
    t.integer  "user_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "is_default",             default: false
    t.string   "address2"
    t.string   "title"
  end

  add_index "address_infos", ["is_default"], name: "index_address_infos_on_is_default", using: :btree

  create_table "friendships", force: :cascade do |t|
    t.integer  "friend_id"
    t.integer  "user_id"
    t.string   "type_of"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  add_index "friendships", ["user_id"], name: "index_friendships_on_user_id", using: :btree

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

  create_table "proposals", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "shipment_id"
    t.decimal  "price",          precision: 10, scale: 2
    t.inet     "ip"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "equipment_type"
  end

  add_index "proposals", ["shipment_id"], name: "index_proposals_on_shipment_id", using: :btree
  add_index "proposals", ["user_id"], name: "index_proposals_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "ship_invitations", force: :cascade do |t|
    t.integer  "shipment_id"
    t.string   "invitee_email"
    t.integer  "invitee_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "ship_invitations", ["invitee_id"], name: "index_ship_invitations_on_invitee_id", using: :btree
  add_index "ship_invitations", ["shipment_id"], name: "index_ship_invitations_on_shipment_id", using: :btree

  create_table "shipment_feedbacks", force: :cascade do |t|
    t.string   "description"
    t.integer  "rate",        null: false
    t.integer  "user_id"
    t.integer  "shipment_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "shipment_feedbacks", ["shipment_id"], name: "index_shipment_feedbacks_on_shipment_id", using: :btree
  add_index "shipment_feedbacks", ["user_id"], name: "index_shipment_feedbacks_on_user_id", using: :btree

  create_table "shipments", force: :cascade do |t|
    t.string   "notes"
    t.string   "picture"
    t.string   "secret_id"
    t.decimal  "weight",               precision: 10, scale: 2, default: 0.0
    t.decimal  "dim_w",                precision: 10, scale: 2, default: 0.0
    t.decimal  "dim_h",                precision: 10, scale: 2, default: 0.0
    t.decimal  "dim_l",                precision: 10, scale: 2, default: 0.0
    t.integer  "distance",                                                      null: false
    t.integer  "n_of_cartons",                                  default: 0
    t.integer  "cubic_feet",                                    default: 0
    t.integer  "unit_count",                                    default: 0
    t.integer  "skids_count",                                   default: 0
    t.integer  "user_id"
    t.integer  "original_shipment_id"
    t.boolean  "hazard",                                        default: false
    t.boolean  "private_proposing",                             default: false
    t.boolean  "active",                                        default: true
    t.boolean  "stackable",                                     default: true
    t.decimal  "price",                precision: 10, scale: 2
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.integer  "shipper_info_id"
    t.integer  "receiver_info_id"
    t.string   "aasm_state",                                                    null: false
    t.datetime "auction_end_at"
    t.string   "po"
    t.string   "pe"
    t.string   "del"
    t.datetime "pickup_at_from"
    t.datetime "pickup_at_to"
    t.datetime "arrive_at_from"
    t.datetime "arrive_at_to"
    t.boolean  "hide_proposals",                                default: false
    t.string   "track_frequency"
  end

  add_index "shipments", ["aasm_state"], name: "index_shipments_on_aasm_state", using: :btree
  add_index "shipments", ["active"], name: "index_shipments_on_active", using: :btree
  add_index "shipments", ["receiver_info_id"], name: "index_shipments_on_receiver_info_id", using: :btree
  add_index "shipments", ["shipper_info_id"], name: "index_shipments_on_shipper_info_id", using: :btree
  add_index "shipments", ["user_id"], name: "index_shipments_on_user_id", using: :btree

  create_table "trackings", force: :cascade do |t|
    t.integer  "shipment_id"
    t.integer  "user_id"
    t.string   "location"
    t.text     "notes"
    t.datetime "checkpoint_time"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "trackings", ["shipment_id"], name: "index_trackings_on_shipment_id", using: :btree
  add_index "trackings", ["user_id"], name: "index_trackings_on_user_id", using: :btree

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
