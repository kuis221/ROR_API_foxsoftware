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

FactoryGirl.define do
  factory :ship_invitation do
    shipment
    invitee_email {FFaker::Internet.email}
  end

end
