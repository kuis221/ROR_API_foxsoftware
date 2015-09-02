class CreateProposals < ActiveRecord::Migration
  def change
    create_table :proposals do |t|
      t.integer :user_id, :shipment_id
      t.decimal :price, precision: 10, scale: 2
      t.inet :ip
      t.timestamps null: false
    end
    add_index :proposals, :user_id
    add_index :proposals, :shipment_id
  end
end
