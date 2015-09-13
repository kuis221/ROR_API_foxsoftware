require 'rails_helper'

RSpec.describe Api::V1::ShipInvitationsController, type: :controller do

  login_user

  context 'shipper' do
    before do
      @logged_in_user.add_role :shipper
      @shipment = create :shipment, user: @logged_in_user
      @inv = create :ship_invitation, shipment: @shipment
    end

    it 'should list shipper created invitations' do
      json_query :get, :index
      expect(@json[:results].size).to eq 1
      expect(@json[:results][0]['status']).to eq 'registered'
    end

    it 'should destroy invitation' do
      expect { json_query :delete, :destroy, id: @inv.id}.to change{ShipInvitation.count}.by(-1)
    end
  end

  it 'should deny for carrier' do
    @logged_in_user.add_role :carrier
    json_query :get, :index
    expect(@json[:error]).to eq 'access_denied_with_role'
  end
end
