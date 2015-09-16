class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.boolean :pick_on_time, :delivery_on_time, :tracking_updated, :had_claims, :will_recommend
      t.integer :user_id, :shipment_id
      t.timestamps null: false
    end
    add_index :ratings, :user_id
    add_index :ratings, :shipment_id
  end
end
