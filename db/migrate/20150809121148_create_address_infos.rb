class CreateAddressInfos < ActiveRecord::Migration
  def change
    create_table :address_infos do |t|
      t.string :type # STI
      t.string :contact_name, :city, :zip_code, :address1, :address2, null: false
      t.string :state, limit: 2, null: false
      t.boolean :appointment, default: false
      t.belongs_to :user
      t.timestamps null: false
    end
  end
end
