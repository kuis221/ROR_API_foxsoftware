class CreateTrackings < ActiveRecord::Migration
  def change
    create_table :trackings do |t|
      t.integer :shipment_id, :user_id
      t.string :location
      t.text :notes
      t.datetime :checkpoint_time
      t.timestamps null: false
    end
    add_index :trackings, :shipment_id
    add_index :trackings, :user_id
  end
end
