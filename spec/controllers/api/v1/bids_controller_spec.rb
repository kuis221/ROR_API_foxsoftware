require 'rails_helper'

describe Api::V1::BidsController do
  let(:attrs) { {price: 22.11, shipment_id: @shipment.id} }

  [:private, :public].each do |way|
    context "Create a new [#{way.to_s.upcase}] bid" do
      login_user
      before do
        @logged_in_user.add_role :carrier
        @shipment = create :shipment, private_bidding: way == :private
        @invitation = create :ship_invitation, shipment: @shipment, invitee: @logged_in_user
      end

      it 'normally' do
        expect {
          json_query :post, :create, bid: attrs
          expect(@json[:status]).to eq 'ok'
        }.to change{Bid.count}.by(1)
      end

      it 'should not create without price' do
        attrs[:price] = nil
        expect {
          json_query :post, :create, bid: attrs
          expect(@json[:error]).to eq 'not_saved'
        }.not_to change{Bid.count}
      end

      it 'should not create without shipment_id' do
        attrs[:shipment_id] = nil
        expect {
          json_query :post, :create, bid: attrs
          expect(@json[:error]).to eq 'not_saved'
        }.not_to change{Bid.count}
      end


      it 'should not create on :limit_reached' do
        # TODO when needed
      end

      if way == :private

        it 'no invitation' do
          @invitation.destroy
          expect {
            json_query :post, :create, bid: attrs
            expect(@json[:error]).to eq 'no_access'
          }.not_to change{Bid.count}
        end

        it 'not active' do
          @shipment.inactive!
          expect {
            json_query :post, :create, bid: attrs
            expect(@json[:error]).to eq 'not_saved'
          }.not_to change{Bid.count}
        end

      end

    end
  end
  context 'not carrier user' do
    login_user
    before do
      @logged_in_user.add_role :client
      @shipment = create :shipment
    end

    it 'should not let other users to bid' do
      expect {
        json_query :post, :create, bid: attrs
        expect(@json[:error]).to eq 'access_denied_with_role'
      }.not_to change{Bid.count}
    end
  end

end
