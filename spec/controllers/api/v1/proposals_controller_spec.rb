require 'rails_helper'

describe Api::V1::ProposalsController do
  let(:attrs) { {price: 22.11, shipment_id: @shipment.id, equipment_type: 'Semi-trailer'} }

  login_user

  shared_examples_for 'proposal_private_resource' do
    before do
      create_resources(:private)
    end
    it 'no invitation' do
      @invitation.destroy
      expect {
        json_query :post, :create, proposal: attrs
        expect(@json[:error]).to eq 'no_access'
      }.not_to change{Proposal.count}
    end

    it 'not active' do
      @shipment.inactive!
      expect {
        json_query :post, :create, proposal: attrs
        expect(@json[:error]).to eq 'not_saved'
      }.not_to change{Proposal.count}
    end
  end

  shared_examples_for 'proposal_resources' do
    before do
      create_resources(way)
    end

    context 'Listing current user proposals' do
      it '- all proposals' do
        proposals = create_list :proposal, 3, user: @logged_in_user, shipment: @shipment
        json_query :get, :index
        expect(@json[:results].size).to eq 3
      end

      it '- scoped by shipment' do
        shipment = create :shipment
        shipment.auction!
        proposals = create_list :proposal, 2, user: @logged_in_user, shipment: shipment
        create_list :proposal, 3, user: @logged_in_user, shipment: @shipment
        json_query :get, :index, shipment_id: @shipment.id # for @shipment object only.
        expect(@json[:results].size).to eq 3
      end

      it 'reject properly' do
        proposal = create :proposal, user: @logged_in_user, shipment: @shipment
        @shipment.offer!
        ActionMailer::Base.deliveries.clear
        expect {
          json_query :put, :reject, id: proposal.id
          proposal.reload
        }.to change(proposal, :rejected_at)
        @shipment.reload
        expect(@shipment.state).to eq :proposing
        expect(ActionMailer::Base.deliveries.count).to eq 1
        body = ActionMailer::Base.deliveries.first.body.raw_source
        expect(body).to include(@logged_in_user.name)
        expect(body).to include('has rejected his proposal for shipment ID')
      end

      it 'cant reject when in not negotiation status' do
        proposal = create :proposal, user: @logged_in_user, shipment: @shipment
        @shipment.offer!
        @shipment.confirm!
        @shipment.picked!
        ActionMailer::Base.deliveries.clear
        expect {
          json_query :put, :reject, id: proposal.id
          proposal.reload
        }.not_to change(proposal, :rejected_at)
        @shipment.reload
        expect(@shipment.state).to eq :in_transit
        expect(ActionMailer::Base.deliveries.count).to eq 0
      end

      it "carrier can't cancel" do
        proposal = create :proposal, user: @logged_in_user, shipment: @shipment
        @shipment.offer!
        email_clear
        expect {
          json_query :put, :cancel, id: proposal.id
          proposal.reload
        }.not_to change(proposal, :rejected_at)
        expect(@json[:error]).to eq 'access_denied_with_role'
        expect_email(0)
      end
    end

    context "Creating a new proposal" do
      it 'normally' do
        expect {
          json_query :post, :create, proposal: attrs
          expect(@json[:status]).to eq 'ok'
          expect(ActionMailer::Base.deliveries.count).to eq 1
          body = ActionMailer::Base.deliveries.first.body.raw_source
          expect(body).to include('You have new proposal for Shipment ID:')
        }.to change{Proposal.count}.by(1)
      end

      it 'should not create without equipment_type' do
        attrs[:equipment_type] = nil
        expect {
          json_query :post, :create, proposal: attrs
          expect(@json[:error]).to eq 'not_saved'
          expect(ActionMailer::Base.deliveries.count).to eq 0
        }.not_to change{Proposal.count}
      end

      it 'should not allow when shipment not in correct state' do
        @shipment.update_attribute :aasm_state, 'draft'
        expect {
          json_query :post, :create, proposal: attrs
          expect(@json[:error]).to eq 'not_in_auction'
        }.not_to change{Proposal.count}
      end

      it 'should not create without price' do
        attrs[:price] = nil
        expect {
          json_query :post, :create, proposal: attrs
          expect(@json[:error]).to eq 'not_saved'
        }.not_to change{Proposal.count}
      end

      it 'should not create without shipment_id' do
        attrs[:shipment_id] = nil
        expect {
          json_query :post, :create, proposal: attrs
          expect(@json[:error]).to eq 'not_saved'
        }.not_to change{Proposal.count}
      end

      it 'should not create when auction_end_at reached' do
        @shipment.update_attribute :auction_end_at, 10.minute.ago
        expect {
          json_query :post, :create, proposal: attrs
          expect(@json[:error]).to eq 'end_auction_date'
        }.not_to change{Proposal.count}
      end

      it 'should not create on :limit_reached' do
        # TODO when needed
      end
    end
  end

  it_behaves_like 'proposal_resources' do
    let(:way) { :private }
    let(:way) { :public }
  end

  it_behaves_like 'proposal_private_resource' do

  end

  context 'shipper user' do
    login_user
    before do
      @logged_in_user.add_role :shipper
      @shipment = create :shipment, aasm_state: :proposing, user: @logged_in_user # auction status
    end

    it 'should not let create proposal' do
      expect {
        json_query :post, :create, proposal: attrs
        expect(@json[:error]).to eq 'access_denied_with_role'
      }.not_to change{Proposal.count}
    end

    it 'should cancel proposal' do
      proposal = create :proposal, shipment: @shipment
      @shipment.offer! # can from this state only
      email_clear
      expect {
        json_query :put, :cancel, id: proposal.id
        proposal.reload
      }.to change(proposal, :rejected_at)
      expect_email(1, 'Your proposal for Shipment ID has been cancelled by the shipper')
    end

    it 'should not cancel from wrong status' do
      proposal = create :proposal, shipment: @shipment
      email_clear
      expect {
        json_query :put, :cancel, id: proposal.id
        proposal.reload
      }.not_to change(proposal, :rejected_at)
      expect(@json[:error]).to eq 'not_valid'
      expect(@json[:text]).to eq 'proposing' # in auction state
      expect_email(0)
    end

    it 'should not find someone other shipment proposal' do
      @shipment.update_attribute :user_id, @logged_in_user.id+1 # just stub to prevent finding it in controller
      proposal = create :proposal, shipment: @shipment
      @shipment.offer! # can from this state only
      email_clear
      expect {
        json_query :put, :cancel, id: proposal.id
        proposal.reload
      }.not_to change(proposal, :rejected_at)
      expect(@json[:error]).to eq 'not_found'
      expect_email(0)
    end

  end

  def create_resources(way)
    @logged_in_user.add_role :carrier
    @shipment = create :shipment, private_proposing: way == :private
    @shipment.auction!
    @invitation = create :ship_invitation, shipment: @shipment, invitee: @logged_in_user
  end
end
