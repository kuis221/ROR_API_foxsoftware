class CreateCommodityFeedbacks < ActiveRecord::Migration
  def change
    create_table :commodity_feedbacks do |t|
      t.string :description
      t.integer :rate, null: false
      t.integer :user_id, :commodity_id
      t.timestamps null: false
    end
    add_index :commodity_feedbacks, :user_id
    add_index :commodity_feedbacks, :commodity_id
  end
end
