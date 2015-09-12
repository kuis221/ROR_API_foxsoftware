class RejectedAtProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :rejected_at, :datetime
  end
end
