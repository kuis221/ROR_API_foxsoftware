require 'rails_helper'

RSpec.describe Api::V1::RatingsController, type: :controller do

  login_user

  let(:attrs) { {pick_on_time: true, delivery_on_time: true, tracking_updated: false, had_claims: false, will_recommend: true, shipment_id: @shipment.id} }

  context 'Shipper' do
    before do
      @logged_in_user.add_role :shipper
      @shipment = create :shipment, user: @logged_in_user
      @shipment.auction!
      proposal = create :proposal, shipment: @shipment
      proposal.offered!
      proposal.accepted!
      @shipment.offer!
      @shipment.confirm!
      @shipment.picked!
    end

    it 'should rate shipment' do
      @shipment.delivered!
      email_clear
      expect {
        json_query :post, :create, rating: attrs
        expect(@json[:status]).to eq 'ok'
      }.to change{Rating.count}.by(1)
      @shipment.reload
      expect(@shipment.state).to eq :completed
      expect_email(1, 'To view rating, click following link:', 'Received rating for shipment')
    end

    it 'should not rate twice' do
      @shipment.delivered!
      rating = create :rating, shipment: @shipment, user: @logged_in_user
      email_clear
      expect {
        json_query :post, :create, rating: attrs
        expect(@json[:error]).to eq 'already_left'
      }.not_to change{Rating.count}
      @shipment.reload
      expect(@shipment.state).to eq :completed
      expect_email(0)
    end

    it 'should not rate in bad_state' do
      email_clear
      expect {
        json_query :post, :create, rating: attrs
      }.not_to change{Rating.count}
      @shipment.reload
      expect(@shipment.state).to eq :in_transit
      expect_email(0)
    end

    it 'should not let carrier to left rating' do
      @logged_in_user.roles.destroy_all
      @logged_in_user.add_role :carrier
      @shipment.delivered!
      email_clear
      expect {
        json_query :post, :create, rating: attrs
      }.not_to change{Rating.count}
      expect(@json[:error]).to eq 'access_denied_with_role'
      @shipment.reload
      expect(@shipment.state).to eq :delivering
      expect_email(0)
    end
  end

  context 'Carrier' do
    before do
      @logged_in_user.add_role :carrier
      shipper = create :shipper
      @shipment = create :shipment, user: shipper
      @shipment.auction!
      @proposal = create :proposal, shipment: @shipment, user: @logged_in_user
      @proposal.offered!
      @proposal.accepted!
      @shipment.offer!
      @shipment.confirm!
      @shipment.picked!
      @shipment.delivered!
      @rating = create :rating, user: shipper, shipment: @shipment
    end

    it 'should read rating by shipment' do
      json_query :get, :read_rating, shipment_id: @shipment.id
      expect(@json[:id]).to eq @rating.id
    end

    it 'should not find rating when not available' do
      @rating.destroy
      json_query :get, :read_rating, shipment_id: @shipment.id
      expect(@json[:error]).to eq 'no_rating'
    end

    it 'should not read someone else rating' do
      @proposal.update_attribute :user_id, @logged_in_user.id+1 # swap user to fail in Ability rule
      json_query :get, :read_rating, shipment_id: @shipment.id
      expect(@json[:error]).to eq 'access_denied_with_role'
    end

  end
end
