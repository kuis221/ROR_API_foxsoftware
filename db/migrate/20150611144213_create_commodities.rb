class CreateCommodities < ActiveRecord::Migration
  def change
    create_table :commodities do |t|
      t.string :description, :picture
      t.decimal :dim_w, :dim_h, :dim_l, precision: 10, scale: 2
      t.integer :distance, :weight, null: false
      t.integer :user_id, :truckload_type
      t.boolean :hazard, default: false
      t.decimal :price, precision: 10, scale: 2
      t.timestamps :pickup_at, :arrive_at, null: false
      t.timestamps null: false
    end
    add_index :commodities, :user_id
    add_index :commodities, :truckload_type
  end
end
