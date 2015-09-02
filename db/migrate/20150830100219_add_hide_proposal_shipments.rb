class AddHideProposalShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :hide_proposals, :boolean, default: false
  end
end
