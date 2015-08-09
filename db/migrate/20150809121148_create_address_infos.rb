class CreateAddressInfos < ActiveRecord::Migration
  def change
    create_table :address_infos do |t|
      t.string :type
      t.string :city, :street, null: false
      t.string :state, limit: 2, null: false
      t.belongs_to :user
      t.integer :home_number, :apartment_number
      t.timestamps null: false
    end
  end
end
