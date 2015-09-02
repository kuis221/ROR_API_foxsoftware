class AddEqTypeProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :equipment_type, :string
  end
end
