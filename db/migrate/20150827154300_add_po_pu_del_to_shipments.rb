class AddPoPuDelToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :po, :string
    add_column :shipments, :pe, :string
    add_column :shipments, :del, :string
  end
end
