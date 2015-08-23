class AddDefaultAddressInfo < ActiveRecord::Migration
  def change
    add_column :address_infos, :is_default, :boolean, default: false
    add_index :address_infos, :is_default
  end
end
