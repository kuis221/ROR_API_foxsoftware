class AddHideBidShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :hide_bids, :boolean, default: false
  end
end
