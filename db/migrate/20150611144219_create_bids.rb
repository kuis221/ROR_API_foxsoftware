class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.integer :user_id, :shipment_id
      t.decimal :price, precision: 10, scale: 2
      t.inet :ip
      t.timestamps null: false
    end
    add_index :bids, :user_id
    add_index :bids, :shipment_id
  end
end
