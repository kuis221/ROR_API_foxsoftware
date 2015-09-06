class LastReviewAtShipment < ActiveRecord::Migration
  def change
    add_column :shipments, :last_review_at, :datetime
  end
end
