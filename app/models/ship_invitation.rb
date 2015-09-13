# == Schema Information
#
# Table name: ship_invitations
#
#  id            :integer          not null, primary key
#  shipment_id   :integer
#  invitee_email :string
#  invitee_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_ship_invitations_on_invitee_id   (invitee_id)
#  index_ship_invitations_on_shipment_id  (shipment_id)
#

class ShipInvitation < ActiveRecord::Base
  belongs_to :shipment
  # Invitee user, may be blank if user not available in our users yet.
  belongs_to :invitee, class_name: 'User', foreign_key: :invitee_id

  scope :for_user, ->(invitee_id) {where(invitee_id: invitee_id)}

  validates_format_of :invitee_email, with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates_presence_of :shipment_id

  def self.invite_by_email!(shipment, email)
    user = User.with_email(email).first
    ship_inv = new invitee_email: email, shipment: shipment
    ship_inv.invitee_id = user.id if user
    ship_inv.save!
    CarrierMailer.send_invitation(shipment, email).deliver_now
    ship_inv
  end

  # Return X number of created invitations
  def self.invite_by_emails!(shipment, emails)
    created = 0
    transaction do
      emails.each do |email|
        ShipInvitation.invite_by_email!(shipment, email)
        created += 1
      end
    end
    created
  end

  # IF invitation has been accepted by user registering with this invitation ?
  # see User#after_create callback
  def status
    invitee.present? ? :registered : :pending
  end
end
