class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.string :notes, :picture, :secret_id
      t.decimal :weight, :dim_w, :dim_h, :dim_l, precision: 10, scale: 2, default: 0.0
      t.integer :distance, null: false
      t.integer :n_of_cartons, :cubic_feet, :unit_count, :skids_count,  default: 0
      t.integer :user_id, :original_shipment_id
      t.boolean :hazard, :private_bidding, default: false
      t.boolean :active, :stackable, default: true
      t.decimal :price, precision: 10, scale: 2
      t.datetime :pickup_at, :arrive_at, null: false
      t.timestamps null: false
    end
    add_index :shipments, :user_id
    add_index :shipments, :active

  end
end
