class CreateDealFeedbacks < ActiveRecord::Migration
  def change
    create_table :deal_feedbacks do |t|
      t.string :type_of, :description
      t.integer :user_id, :deal_id
      t.timestamps null: false
    end
    add_index :deal_feedbacks, :user_id
    add_index :deal_feedbacks, :deal_id
  end
end
