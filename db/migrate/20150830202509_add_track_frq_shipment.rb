class AddTrackFrqShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :track_frequency, :string
  end
end
