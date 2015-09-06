class AddProposedAtProposal < ActiveRecord::Migration
  def change
    add_column :proposals, :offered_at, :datetime   # by shipper
    add_column :proposals, :accepted_at, :datetime  # by carrier
  end
end
