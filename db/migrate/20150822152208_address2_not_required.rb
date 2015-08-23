class Address2NotRequired < ActiveRecord::Migration
  def change
    remove_column :address_infos, :address2
    AddressInfo.reset_column_information
    add_column :address_infos, :address2, :string
  end
end
