class AddAuctionEndAtShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :auction_end_at, :datetime
  end
end
