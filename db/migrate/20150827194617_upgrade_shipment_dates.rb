class UpgradeShipmentDates < ActiveRecord::Migration
  def change
    change_table :shipments do |t|
      t.remove :pickup_at, :arrive_at
      t.datetime :pickup_at_from, :pickup_at_to, :arrive_at_from, :arrive_at_to
    end
  end
end
