require 'rails_helper'

describe Api::V1::ShipmentsController do

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
      @shipment = create :shipment, private_proposing: true # secret_id
    end

    it 'check carrier ability' do
      expect(@logged_in_user.has_role?(:carrier)).to eq true
    end

    it 'should read invited shipment' do
      json_query :get, :show, id: @shipment.id, invitation: @shipment.secret_id
      expect(@json[:id]).to eq @shipment.id
      keys =  Api::V1::ShipmentPresenter::HASH
      keys.each do |key|
        expect(@json[key.to_sym].to_s).to eq @shipment[key].to_s
      end
    end

    it 'should not read invited shipment with wrong secret_id' do
      # ship_invs = create_list :ship_invitation, 2
      inv = create :ship_invitation, shipment: @shipment
      json_query :get, :show, id: @shipment.id, invitation: '!@#fokd'
      expect(@json[:error]).to eq 'unauthorized'
    end

    it 'should display only my invites in my_invitations' do
      other_ship_invs = create_list :ship_invitation, 2
      my_ship_invs = create_list :ship_invitation, 3, invitee: @logged_in_user # with related shipments
      json_query :get, :my_invitations
      expect(@json[:results].size).to eq 3
      my_ships = my_ship_invs.map &:shipment_id
      expect(@json[:results].collect{|x| x['id']}).to eq my_ships
    end

    context 'list lowest_proposal action' do
      before do
        @ship_inv = create :ship_invitation, invitee: @logged_in_user
        @shipment = @ship_inv.shipment
        @shipment.auction!
        @shipment.private!
        @proposal = create :proposal, shipment: @shipment, price: 100.55, user: @logged_in_user
      end

      it 'should show it, and hide proposalder' do
        json_query :get, :lowest_proposal, id: @shipment.id
        expect(@json[:price]).to eq '100.55'
        expect(@json[:user]).to be nil
        # expect(@json[:user]['id']).to eq 0
        # expect(@json[:user]['name']).to eq ''
      end

      it 'should render 404 for non existent shipment' do
        @shipment.destroy
        json_query :get, :lowest_proposal, id: @shipment.id
        expect(@json[:error]).to eq 'not_found'
      end

      it 'should not show for other private shipment' do
        @ship_inv.destroy
        json_query :get, :lowest_proposal, id: @shipment.id
        expect(@json[:error]).to eq 'no_access'
      end

      it 'should not show inactive shipment' do
        @shipment.inactive!
        json_query :get, :lowest_proposal, id: @shipment.id
        expect(@json[:error]).to eq 'not_found'
      end
    end


    context 'shipments and proposals' do
      before do
        @ship_inv = create :ship_invitation, invitee: @logged_in_user
        @shipment = @ship_inv.shipment
        @shipment.auction!
        # public shipment only
        @proposals = []
        4.times do |b|
          @proposals << (create :proposal, shipment: @shipment, price: b*10, user: @logged_in_user)
        end
      end

      it 'should list and not disclose proposalders' do
        json_query :get, :current_proposals, id: @shipment.id
        expect(@json[:results].size).to eq 4
        last = 10000.0 # shouldnot be more than rand 9999
        # check that results sorted by price :)
        @json[:results].each do |res|
          expect(res['user']).to eq nil
          expect(res['price'].to_f < last).to be true
          last = res['price'].to_f
        end
      end

      it 'should list shipments with proposals summaries' do
        json_query :get, :index, user_id: @shipment.user_id
        expect(@json[:results].size).to eq 1
        low_proposal  = @shipment.low_proposal
        high_proposal = @shipment.high_proposal
        avg_proposal = @shipment.avg_proposal
        expect(@json[:results][0]['proposals']['low']).to eq low_proposal.to_s
        expect(@json[:results][0]['proposals']['high']).to eq high_proposal.to_s
        expect(@json[:results][0]['proposals']['avg']).to eq avg_proposal.to_s
      end

      it 'should list shipments without proposals summaries' do
        @shipment.hide_proposals!
        json_query :get, :index, user_id: @shipment.user_id
        expect(@json[:results].size).to eq 1
        expect(@json[:results][0]['proposals']).to be nil
      end

      it 'should render 404 for non existent shipment' do
        @shipment.destroy
        json_query :get, :current_proposals, id: @shipment.id
        expect(@json[:error]).to eq 'not_found'
      end

      it 'should not show private shipment without ship invitation' do
        @ship_inv.destroy
        @shipment.private!
        json_query :get, :current_proposals, id: @shipment.id
        expect(@json[:error]).to eq 'no_access'
      end

      it 'should not show inactive shipment' do
        @shipment.inactive!
        json_query :get, :current_proposals, id: @shipment.id
        expect(@json[:error]).to eq 'no_access'
      end

      it 'should not list private shipments' do
        @shipment.private!
        json_query :get, :index, user_id: @shipment.user_id
        expect(@json[:results]).to eq []
      end
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

      it 'should exclude from my_invitations' do
        json_query :get, :my_invitations
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
      it 'should let client list his shipments' do
        create_list :shipment, 2, user: @logged_in_user
        json_query :get, :index
        expect(@json[:results].size).to eq 2
        expect(@json[:results].first['active']).to eq true
      end

      it 'should let client list his shipment with proposals, even not active' do
        shipment = create :shipment, user: @logged_in_user, private_proposing: false, active: false
        shipment.auction!
        proposals_count = (rand*10).to_i
        proposals_count.times do |proposals|
          create :proposal, shipment: shipment
        end
        json_query :get, :current_proposals, id: shipment.id
        expect(@json[:results].size).to eq proposals_count
        expect(@json[:results][0]['user']['name']).not_to eq ''
      end

      it 'should not let client list other shipments' do
        create_list :shipment, 2
        json_query :get, :index
        expect(@json[:results].size).to eq 0
      end

    end

    context 'saving' do
      let(:attrs) { {shipper_info_id: @shipper_info.id, receiver_info_id: @receiver_info.id, dim_w: 10, dim_h: 20.22, dim_l: 30.3, distance: 50, notes: 'TEST DS', price: 1005.22, pickup_at_from: 2.days.from_now.to_s, arrive_at_from: 3.days.from_now.to_s, auction_end_at: 2.days.from_now.to_s} }
      before do
        @shipper_info = create :shipper_info, user: @logged_in_user
        @receiver_info = create :receiver_info, user: @logged_in_user
        allow(InviteCarriers).to receive(:perform_async)
        @invs = ['some@email.com', 'other@email.com']
      end

      it 'should let client create new shipment with invitations' do
        expect {
          json_query :post, :create, shipment: attrs, invitations: {emails: @invs}
          expect(InviteCarriers).to have_received(:perform_async).exactly(1).with(@json[:id], @invs)
        }.to change{Shipment.count}
        expect(Shipment.find(@json[:id]).state).to eq :proposing
        expect(@json[:secret_id]).not_to be blank?
      end

      it 'should let client create new shipment as draft' do
        expect {
          json_query :post, :create, shipment: attrs, state: 'pending'
        }.to change{Shipment.count}
        expect(Shipment.find(@json[:id]).state).to eq :pending
      end

      it "can't create without auction_end_date" do
        attrs[:auction_end_at] = nil
        expect {
          json_query :post, :create, shipment: attrs, invitations: {emails: @invs}
          expect(InviteCarriers).not_to have_received(:perform_async)
          expect(@json[:error]).to eq 'not_saved'
          expect(@json[:text].size).to eq 1 # blank and bad association
        }.not_to change{Shipment.count}
      end

      # it "cant't create with messed dates" do
      #  TODO test that its not possible to cross the dates of shipment, for example when any arrive at earlier that pickup
      #   at this stage its not needed
      # end

      it 'cant accept without ShipperInfo or ReceiverInfo' do
        attrs[:shipper_info_id] = nil
        expect {
          json_query :post, :create, shipment: attrs, invitations: {emails: @invs}
          expect(InviteCarriers).not_to have_received(:perform_async)
          expect(@json[:error]).to eq 'not_saved'
          expect(@json[:text].size).to eq 2 # blank and bad association
        }.not_to change{Shipment.count}
      end

      it "can't assign someone's else addesses" do
        someone_shipper_info = create :shipper_info
        attrs[:shipper_info_id] = someone_shipper_info.id
        expect {
          json_query :post, :create, shipment: attrs, invitations: {emails: @invs}
          expect(InviteCarriers).not_to have_received(:perform_async)
          expect(@json[:error]).to eq 'not_saved'
          expect(@json[:text].size).to eq 1 # bad association
        }.not_to change{Shipment.count}
      end

      it 'should not let client create invalid shipment' do
        attrs[:price] = nil
        expect {
          json_query :post, :create, shipment: attrs
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
