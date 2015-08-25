require 'rails_helper'

describe Api::V1::ShipmentsController do

  # before do
  #   @user = create :user
  #   @shipment = create :shipment, user: @user
  # end

  context 'unauthorized browsing' do
    it 'should not let visitors read shipment(s)' do
      shipment = create :shipment
      json_query :get, :show, id: shipment.id
      expect(@json[:errors].size).to eq 1
    end
  end

  context 'Carrier browsing shipments' do
    login_user

    before do
      @logged_in_user.add_role :carrier
      @shipment = create :shipment, private_bidding: true # secret_id
    end

    it 'check carrier ability' do
      expect(@logged_in_user.has_role?(:carrier)).to eq true
    end

    it 'should read invited shipment' do
      json_query :get, :show, id: @shipment.id, invitation: @shipment.secret_id
      expect(@json[:id]).to eq @shipment.id
      # check for proper hash respond(should not return all attrs like for owner of shipment)
      expect(@json[:private_bidding]).to be nil
    end

    it 'should not read invited shipment with wrong secret_id' do
      # ship_invs = create_list :ship_invitation, 2
      inv = create :ship_invitation, shipment: @shipment
      json_query :get, :show, id: @shipment.id, invitation: '!@#fokd'
      expect(@json[:error]).to eq 'unauthorized'
    end

    it 'should display only my invites in my_listing' do
      other_ship_invs = create_list :ship_invitation, 2
      my_ship_invs = create_list :ship_invitation, 3, invitee: @logged_in_user # with related shipments
      json_query :get, :my_listing
      expect(@json[:results].size).to eq 3
      my_ships = my_ship_invs.map &:shipment_id
      expect(@json[:results].collect{|x| x['id']}).to eq my_ships
    end

    context 'inactive shipment' do
      before do
        @shipment.inactive!
        create :ship_invitation, shipment: @shipment
      end

      it 'should not show' do
        json_query :get, :show, id: @shipment.id, invitation: @shipment.secret_id
        expect(@json[:error]).to eq 'not_eligible'
      end

      it 'should exclude from index' do
        json_query :get, :index
        expect(@json[:results]).to eq []
      end

      it 'should exclude from my_listing' do
        json_query :get, :my_listing
        expect(@json[:results]).to eq []
      end
    end

  end

  context 'Client shipments manipulations' do

    login_user

    before do
      @logged_in_user.add_role :client
    end

    context 'listing' do
      it 'should let client list its shipments' do
        create_list :shipment, 2, user: @logged_in_user
        json_query :get, :index
        expect(@json[:results].size).to eq 2
        expect(@json[:results].first['active']).to eq true
      end

      it 'should not let client list other shipments' do
        create_list :shipment, 2
        json_query :get, :index
        expect(@json[:results].size).to eq 0
      end

      context 'highest_bid action' do
        before do
          @ship_inv = create :ship_invitation, invitee: @logged_in_user
          @shipment = @ship_inv.shipment
          @shipment.private!
          @bid = create :bid, shipment: @shipment, price: 100.55, user: @logged_in_user
        end

        it 'should show' do
          json_query :get, :highest_bid, id: @shipment.id
          expect(@json[:price]).to eq '100.55'
          expect(@json[:user]['id']).to eq @logged_in_user.id
        end

        it 'should render 404 for non existent shipment' do
          @shipment.destroy
          json_query :get, :highest_bid, id: @shipment.id
          expect(@json[:error]).to eq 'not_found'
        end

        it 'should not show for other private shipment' do
          @ship_inv.destroy
          json_query :get, :highest_bid, id: @shipment.id
          expect(@json[:error]).to eq 'no_access'
        end

        it 'should not show inactive shipment' do
          @shipment.inactive!
          json_query :get, :highest_bid, id: @shipment.id
          expect(@json[:error]).to eq 'not_found'
        end
      end

      context 'current_bids action' do
        before do
          @ship_inv = create :ship_invitation, invitee: @logged_in_user
          @shipment = @ship_inv.shipment
          @shipment.private!
          @bids = []
          4.times do |b|
            @bids << (create :bid, shipment: @shipment, price: b*10, user: @logged_in_user)
          end
        end

        it 'should list' do
          json_query :get, :current_bids, id: @shipment.id
          expect(@json[:results].size).to eq 4
          last = 10000.0 # shouldnot be more than rand 9999
          # check that results sorted by price :)
          @json[:results].each do |res|
            expect(res['price'].to_f < last).to be true
            last = res['price'].to_f
          end
        end

        it 'should render 404 for non existent shipment' do
          @shipment.destroy
          json_query :get, :current_bids, id: @shipment.id
          expect(@json[:error]).to eq 'not_found'
        end

        it 'should not show for other private shipment' do
          @ship_inv.destroy
          json_query :get, :current_bids, id: @shipment.id
          expect(@json[:error]).to eq 'no_access'
        end

        it 'should not show inactive shipment' do
          @shipment.inactive!
          json_query :get, :current_bids, id: @shipment.id
          expect(@json[:error]).to eq 'not_found'
        end
      end
    end

    context 'saving' do
      before do
        @shipper_info = create :shipper_info, user: @logged_in_user
        @receiver_info = create :receiver_info, user: @logged_in_user
        @attrs = {shipper_info_id: @shipper_info.id, receiver_info_id: @receiver_info.id, dim_w: 10, dim_h: 20.22, dim_l: 30.3, distance: 50, notes: 'TEST DS', price: 1005.22, pickup_at: 2.days.from_now.to_s, arrive_at: 3.days.from_now.to_s}
        allow(InviteCarriers).to receive(:perform_async)
        @invs = ['some@email.com', 'other@email.com']
      end

      it 'should let client create new shipment with invitations' do
        expect {
          json_query :post, :create, shipment: @attrs, invitations: {emails: @invs}
          expect(InviteCarriers).to have_received(:perform_async).exactly(1).with(@json[:id], @invs)
        }.to change{Shipment.count}
        expect(@json[:secret_id]).not_to be blank?
      end

      it 'cant accept without ShipperInfo or ReceiverInfo' do
        @attrs[:shipper_info_id] = nil
        expect {
          json_query :post, :create, shipment: @attrs, invitations: {emails: @invs}
          expect(InviteCarriers).not_to have_received(:perform_async)
          expect(@json[:error]).to eq 'not_saved'
          expect(@json[:text].size).to eq 2 # blank and bad association
        }.not_to change{Shipment.count}
      end

      it "can't assign someone's else addesses" do
        someone_shipper_info = create :shipper_info
        @attrs[:shipper_info_id] = someone_shipper_info.id
        expect {
          json_query :post, :create, shipment: @attrs, invitations: {emails: @invs}
          expect(InviteCarriers).not_to have_received(:perform_async)
          expect(@json[:error]).to eq 'not_saved'
          expect(@json[:text].size).to eq 1 # bad association
        }.not_to change{Shipment.count}
      end

      it 'should not let client create invalid shipment' do
        @attrs[:price] = nil
        expect {
          json_query :post, :create, shipment: @attrs
          expect(@json[:error]).not_to be blank?
          expect(@json[:text][0]).to eq "Price can't be blank"
          expect(InviteCarriers).not_to have_received(:perform_async)
        }.not_to change{Shipment.count}
      end

      context 'editing' do
        before do
          @shipment = create :shipment, user: @logged_in_user
        end

        it 'should let client edit its own shipment' do
          expect {
            json_query :put, :update, id: @shipment.id, shipment: {price: 22.32}
            expect(@json[:status]).to eq 'ok'
            @shipment.reload
          }.to change(@shipment, :price)
        end

        it 'should change ReceiverInfo' do
          new_receiver_info = create :receiver_info, user: @logged_in_user
          expect {
            json_query :put, :update, id: @shipment.id, shipment: {receiver_info_id: new_receiver_info.id}
            expect(@json[:status]).to eq 'ok'
            @shipment.reload
          }.to change(@shipment, :receiver_info_id)
        end

        it 'should not change ReceiverInfo for not owned object' do
          new_receiver_info = create :receiver_info
          expect {
            json_query :put, :update, id: @shipment.id, shipment: {receiver_info_id: new_receiver_info.id}
            expect(@json[:error]).to eq 'not_saved'
            expect(@json[:text].size).to eq 1 # bad association labeling
            @shipment.reload
          }.not_to change(@shipment, :price)
        end

        it 'should not let client save bad details' do
          expect {
            json_query :put, :update, id: @shipment.id, shipment: {price: ''}
            expect(@json[:error]).to eq 'not_saved'
            @shipment.reload
          }.not_to change(@shipment, :price)
        end

        it "should not let client edit someone's shipment" do
          shipment = create :shipment
          expect {
            json_query :put, :update, id: shipment.id, shipment: {price: '22222.22'}
            expect(@json[:error]).to eq 'not_found'
            shipment.reload
          }.not_to change(shipment, :price)
        end

        it 'should delete shipment' do
          expect {
           json_query :delete, :destroy, id: @shipment.id
            expect(@json[:status]).to eq 'ok'
          }.to change{Shipment.count}.by(-1)
        end

        it 'should make inactive shipment' do
          expect {
            json_query :post, :toggle_active, id: @shipment.id
            @shipment.reload
          }.to change(@shipment, :active)
        end

      end
    end

  end

end
