class AddEqTypeBid < ActiveRecord::Migration
  def change
    add_column :bids, :equipment_type, :string
  end
end
