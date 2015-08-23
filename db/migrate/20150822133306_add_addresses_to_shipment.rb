class AddAddressesToShipment < ActiveRecord::Migration
  def change
    change_table :shipments do |t|
      t.belongs_to :shipper_info
      t.belongs_to :receiver_info
    end
    add_index :shipments, :shipper_info_id
    add_index :shipments, :receiver_info_id
  end
end
