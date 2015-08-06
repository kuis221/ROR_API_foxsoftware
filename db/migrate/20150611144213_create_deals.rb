class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.string :description, :picture, :type_of
      t.integer :quantity, :user_id
      t.decimal :price, precision: 10, scale: 2
      t.timestamps null: false
    end
    add_index :deals, :user_id
  end
end
