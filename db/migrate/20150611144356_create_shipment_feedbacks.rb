class CreateShipmentFeedbacks < ActiveRecord::Migration
  def change
    create_table :shipment_feedbacks do |t|
      t.string :description
      t.integer :rate, null: false
      t.integer :user_id, :shipment_id
      t.timestamps null: false
    end
    add_index :shipment_feedbacks, :user_id
    add_index :shipment_feedbacks, :shipment_id
  end
end
