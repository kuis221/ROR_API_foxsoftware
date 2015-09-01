require 'rails_helper'

describe Api::V1::BidsController do
  let(:attrs) { {price: 22.11, shipment_id: @shipment.id, equipment_type: 'Semi-trailer'} }

  login_user

  shared_examples_for 'bid_private_resource' do
    before do
      create_resources(:private)
    end
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

  shared_examples_for 'bid_resources' do
    before do
      create_resources(way)
    end
    context 'Listing current user bids' do
      it '- all bids' do
        bids = create_list :bid, 3, user: @logged_in_user, shipment: @shipment
        json_query :get, :index
        expect(@json[:results].size).to eq 3
      end

      it '- scoped by shipment' do
        shipment = create :shipment
        shipment.auction!
        bids = create_list :bid, 2, user: @logged_in_user, shipment: shipment
        create_list :bid, 3, user: @logged_in_user, shipment: @shipment
        json_query :get, :index, shipment_id: @shipment.id # for @shipment object only.
        expect(@json[:results].size).to eq 3
      end
    end

    context "Creating a new bid" do
      it 'normally' do
        expect {
          json_query :post, :create, bid: attrs
          expect(@json[:status]).to eq 'ok'
          expect(ActionMailer::Base.deliveries.count).to eq 1
          body = ActionMailer::Base.deliveries.first.body.raw_source
          expect(body).to include('You have new bid for Shipment ID:')
        }.to change{Bid.count}.by(1)
      end

      it 'should not create without equipment_type' do
        attrs[:equipment_type] = nil
        expect {
          json_query :post, :create, bid: attrs
          expect(@json[:error]).to eq 'not_saved'
          expect(ActionMailer::Base.deliveries.count).to eq 0
        }.not_to change{Bid.count}
      end

      it 'should not allow when shipment not in correct state' do
        @shipment.update_attribute :aasm_state, 'pending'
        expect {
          json_query :post, :create, bid: attrs
          expect(@json[:error]).to eq 'not_in_auction'
        }.not_to change{Bid.count}
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

      it 'should not create when auction_end_at reached' do
        @shipment.update_attribute :auction_end_at, 10.minute.ago
        expect {
          json_query :post, :create, bid: attrs
          expect(@json[:error]).to eq 'end_auction_date'
        }.not_to change{Bid.count}
      end

      it 'should not create on :limit_reached' do
        # TODO when needed
      end
    end
  end

  it_behaves_like 'bid_resources' do
    let(:way) { :private }
    let(:way) { :public }
  end

  it_behaves_like 'bid_private_resource' do

  end

  context 'not a carrier user' do
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

  def create_resources(way)
    @logged_in_user.add_role :carrier
    @shipment = create :shipment, private_bidding: way == :private
    @shipment.auction!
    @invitation = create :ship_invitation, shipment: @shipment, invitee: @logged_in_user
  end
end
