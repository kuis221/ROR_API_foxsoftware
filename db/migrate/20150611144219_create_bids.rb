class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.integer :seller_id, :buyer_id, :commodity_id
      t.decimal :price, precision: 10, scale: 2
      t.inet :ip
      t.timestamps null: false
    end
    add_index :bids, :seller_id
    add_index :bids, :buyer_id
    add_index :bids, :commodity_id
  end
end
