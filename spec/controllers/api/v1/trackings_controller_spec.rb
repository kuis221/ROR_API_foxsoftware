require 'rails_helper'

RSpec.describe Api::V1::TrackingsController, type: :controller do
  let(:attrs) { {shipment_id: @shipment.id, location: 'Somewhere', checkpoint_time: 1.hour.ago.to_s} }

  login_user
  # shared_examples_for 'trackings' do
  #
  # end
  #
  # it_behaves_like 'tracking' do
  #   let(:role) { :shipper }
  #   let(:role) { :carrier }
  # end
  context 'shipper' do
    before do
      @logged_in_user.add_role :shipper
    end

    it 'should load shipper shipment trackings' do
      shipment = create :shipment, user: @logged_in_user, aasm_state: :in_transit
      user = create :carrier
      create_list :tracking, 4, shipment: shipment, user: user
      json_query :get, :index, shipment_id: shipment.id
      expect(@json[:results].size).to eq 4
    end

    it 'should not load other shipper trackings' do
      user = create :shipper
      shipment = create :shipment, user: user, aasm_state: :in_transit
      create_list :tracking, 1, shipment: shipment
      json_query :get, :index, shipment_id: shipment.id
      expect(@json[:error]).to eq 'access_denied_with_role'
    end

    it 'should not destroy' do
      shipment = create :shipment, user: @logged_in_user, aasm_state: :in_transit
      tracking = create :tracking, shipment: shipment
      expect {
        json_query :delete, :destroy, id: tracking.id
      }.not_to change{Tracking.count}
      expect(@json[:error]).to eq 'access_denied_with_role'
    end

    it 'should not let create' do
      @shipment = create :shipment, user: @logged_in_user, aasm_state: :in_transit
      expect {
        json_query :post, :create, tracking: attrs
      }.not_to change{Tracking.count}
      expect(@json[:error]).to eq 'access_denied_with_role'
    end
  end

  context 'carrier' do
    before do
      @shipment = create :shipment, aasm_state: :in_transit
      @logged_in_user.add_role :carrier
    end
    it 'should load trackings' do
      create_list :tracking, 4, user: @logged_in_user, shipment: @shipment
      json_query :get, :index, shipment_id: @shipment.id
      expect(@json[:results].size).to eq 4
    end

    context 'create new' do

      it 'normally' do
         expect {
           json_query :post, :create, tracking: attrs
           expect(ActionMailer::Base.deliveries.count).to eq 1
           body = ActionMailer::Base.deliveries.first.body.raw_source
           expect(body).to include('New tracking added to your shipment ID:')
         }.to change{Tracking.count}.by(1)
      end

      it "cant create while shipment not in 'in_transit' state" do
        @shipment.update_attribute :aasm_state, 'pending'
        expect {
          json_query :post, :create, tracking: attrs
        }.not_to change{Tracking.count}
        expect(@json[:error]).to eq 'not_saved'
      end

      it 'should not let create with missing details' do
        attrs[:shipment_id] = nil
        expect {
          json_query :post, :create, tracking: attrs
        }.not_to change{Tracking.count}
      end

      it 'should destroy it' do
        tracking = create :tracking, user: @logged_in_user, shipment: @shipment
        expect {
          json_query :delete, :destroy, id: tracking.id
        }.to change{Tracking.count}.by(-1)
      end

      it 'should not destroy someone else' do
        tracking = create :tracking, shipment: @shipment
        expect {
          json_query :delete, :destroy, id: tracking.id
        }.not_to change{Tracking.count}
        expect(@json[:error]).to eq 'access_denied_with_role'
      end
    end
  end



end
