class AddTitleAddressInfo < ActiveRecord::Migration
  def change
    add_column :address_infos, :title, :string
  end
end
