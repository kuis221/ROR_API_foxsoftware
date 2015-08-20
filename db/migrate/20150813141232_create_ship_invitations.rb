class CreateShipInvitations < ActiveRecord::Migration
  def change
    create_table :ship_invitations do |t|
      t.belongs_to :shipment
      t.string :invitee_email
      t.integer :invitee_id
      t.timestamps null: false
    end
    add_index :ship_invitations, :shipment_id
    add_index :ship_invitations, :invitee_id

  end
end
