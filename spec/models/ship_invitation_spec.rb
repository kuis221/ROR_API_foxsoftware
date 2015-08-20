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

require 'rails_helper'

RSpec.describe ShipInvitation, type: :model do

  context 'creating' do
    before do
      @shipment = create :shipment
    end

    it 'should create when no user present' do
      email = FFaker::Internet.email
      expect {
        ship_inv = ShipInvitation.invite_by_email!(@shipment, email)
        expect(ship_inv.invitee_email).to eq email
      }.to change{ShipInvitation.count}.by(1)
    end

    it 'should create multiple invitations' do
      emails = []
      3.times { emails << FFaker::Internet.email }
      expect{
        expect(ShipInvitation.invite_by_emails!(@shipment, emails)).to eq 3
        expect(ActionMailer::Base.deliveries.size).to eq 3
      }.to change{ShipInvitation.count}.by(3)
    end
  end
end
