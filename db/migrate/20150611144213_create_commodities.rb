class CreateCommodities < ActiveRecord::Migration
  def change
    create_table :commodities do |t|
      t.string :description, :picture
      t.integer :distance, null: false
      t.integer :user_id, :truckload_type
      t.decimal :price, precision: 10, scale: 2
      t.timestamps null: false
    end
    add_index :commodities, :user_id
    add_index :commodities, :truckload_type
  end
end
