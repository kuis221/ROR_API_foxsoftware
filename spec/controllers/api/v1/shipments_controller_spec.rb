require 'rails_helper'

describe Api::V1::ShipmentsController do

  context 'unauthorized browsing' do
    it 'should not let visitors read shipment(s)' do
      shipment = create :shipment
      json_query :get, :show, id: shipment.id
      expect(@json[:errors].size).to eq 1
    end
  end


  shared_examples_for 'POST action' do |role, way|
    login_user

    before do
      @logged_in_user.add_role role
      @shipper = create :user if role == :carrier # create some other shipper who own the @shipment in carrier scenarios
      @shipment = create :shipment, private_proposing: way == :private, user: (role == :shipper ? @logged_in_user : @shipper)
      @invitation = create :ship_invitation, shipment: @shipment, invitee: @logged_in_user if role == :carrier
    end

    it 'access_denied' do
      shipment = create :shipment
      json_query :post, :set_status, {id: shipment.id, status: 'auction'}
      expect(@json[:error]).to eq 'access_denied'
    end

    # Not allow carrier to set this status(eg: 'bad_role').
    it 'to auction' do
      json_query :post, :set_status, {id: @shipment.id, status: 'auction'}
      if role == :shipper
        expect(@json[:status]).to eq 'ok'
        @shipment.reload
        expect(@shipment.state).to eq :proposing
      else # carrier
        expect(@json[:error]).to eq 'bad_role'
      end
    end

    it 'to pause' do
      @shipment.auction!  # >> ff
      @shipment.offer!    # fast forward to proposing
      create_list :proposal, 3, shipment: @shipment
      json_query :post, :set_status, {id: @shipment.id, status: 'pause'}
      if role == :shipper
        expect(@json[:status]).to eq 'ok'
        @shipment.reload
        expect(@shipment.proposals.count).to eq 0 # remove proposals after this status in after_transition callback
        expect(@shipment.state).to eq :draft
      else # carrier
        expect(@json[:error]).to eq 'bad_role'
      end
    end

    # Has to test with and without(bad_proposal_id) proposal id !
    # TODO to offer without proposal id. when tested manually - its pass the test.
    it 'to offer with proposal_id' do
      @shipment.auction! # ff
      proposal = create :proposal, shipment: @shipment
      json_query :post, :set_status, {id: @shipment.id, status: 'offer', proposal_id: proposal.id}
      if role == :shipper
        expect(@json[:status]).to eq 'ok'
        @shipment.reload
        proposal.reload
        expect(proposal.offered_at).not_to be_falsey
        expect(@shipment.state).to eq :pending
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to.first).to eq proposal.user.email
        expect(mail.subject).to eq 'You got offer for your proposal!'
      else
        expect(@json[:error]).to eq 'bad_role'
      end
    end

    # TODO to offer without proposal id. when tested manually - its pass the test.
    it 'to confirm with proposal_id' do
      # Fast forward
      @shipment.auction!
      @shipment.offer!
      bidder = create :user# if role == :carrier
      proposal = create :proposal, shipment: @shipment, user: (role == :carrier ? @logged_in_user : bidder ), offered_at: Time.zone.now
      other_proposal = create :proposal, shipment: @shipment
      ActionMailer::Base.deliveries.clear
      json_query :post, :set_status, {id: @shipment.id, status: 'confirm', proposal_id: proposal.id}
      if role == :shipper
        expect(@json[:error]).to eq 'bad_role'
      else
        expect(@json[:status]).to eq 'ok'
        @shipment.reload
        proposal.reload
        expect(proposal.accepted_at).not_to be_falsey
        expect(@shipment.state).to eq :confirming
        # Check that shipper get an email
        shipper_mail = ActionMailer::Base.deliveries.first
        expect(shipper_mail.to.first).to eq @shipment.user.email
        expect(shipper_mail.subject).to eq "Carrier has accepted your offer for shipment: #{@shipment.id}"

        # Should let other carriers that their proposals are rejected
        rejected_mail = ActionMailer::Base.deliveries.last # rejected email to other carriers
        expect(rejected_mail.to.first).to eq other_proposal.user.email
        expect(rejected_mail.subject).to eq 'Your proposal has been rejected'
      end
    end

    it 'to in_transit' do
      # Fast forward
      @shipment.auction!
      @shipment.offer!
      @shipment.confirm!
      json_query :post, :set_status, {id: @shipment.id, status: 'in_transit'}
      if role == :shipper
        expect(@json[:error]).to eq 'bad_role'
      else
        expect(@json[:status]).to eq 'ok'
        @shipment.reload
        expect(@shipment.state).to eq :in_transit
      end
    end

    it 'to delivered' do
      # Fast forward
      @shipment.auction!
      @shipment.offer!
      @shipment.confirm!
      @shipment.picked!
      json_query :post, :set_status, {id: @shipment.id, status: 'delivered'}
      if role == :shipper
        expect(@json[:error]).to eq 'bad_role'
      else
        expect(@json[:status]).to eq 'ok'
        @shipment.reload
        expect(@shipment.state).to eq :delivering
        shipper_mail = ActionMailer::Base.deliveries.last
        expect(shipper_mail.to.first).to eq @shipment.user.email
        expect(shipper_mail.subject).to eq "Your shipment: #{@shipment.id} has been delivered"
      end
    end

    it 'cant set to completed' do
      # Fast forward
      @shipment.auction!
      @shipment.offer!
      @shipment.confirm!
      @shipment.picked!
      @shipment.delivered!
      json_query :post, :set_status, {id: @shipment.id, status: 'completed'}
      expect(@json[:error]).to eq 'bad_status'
    end

    # Cant pause from confirmed
    it 'bad_transition' do
      if role == :shipper
        @shipment.auction!
        @shipment.offer!
        @shipment.confirm!
        json_query :post, :set_status, {id: @shipment.id, status: 'pause'}
        expect(@json[:error]).to eq 'bad_transition'
      end
    end

  end

  describe 'Changing shipment status' do
    it_should_behave_like 'POST action', :carrier, :private
    it_should_behave_like 'POST action', :carrier, :public
    it_should_behave_like 'POST action', :shipper, :private
    it_should_behave_like 'POST action', :shipper, :public
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

    it 'should not list unlisted shipments' do
      shipper = @shipment.user
      @shipment.auction!
      @shipment.update_attribute :private_proposing, false
      create_list :shipment, 3, user: shipper, aasm_state: 'confirming', private_proposing: false
      json_query :get, :index, user_id: shipper.id
      expect(@json[:results].size).to eq 1 # see only auction state
    end

    it 'should read invited shipment' do
      json_query :get, :show, id: @shipment.id, invitation: @shipment.secret_id
      expect(@json[:id]).to eq @shipment.id
      keys =  Api::V1::ShipmentPresenter::HASH_show
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
      shipment = create :shipment, private_proposing: true
      shipment.auction!
      my_ship_invs = create_list :ship_invitation, 3, invitee: @logged_in_user, shipment: shipment # with related shipments

      json_query :get, :my_invitations
      expect(@json[:results].size).to eq 3
      my_ships = my_ship_invs.map &:shipment_id
      expect(@json[:results].collect{|x| x['id']}.sort).to eq my_ships
    end

    context 'list lowest_proposal action' do
      before do
        @ship_inv = create :ship_invitation, invitee: @logged_in_user
        @shipment = @ship_inv.shipment
        @shipment.auction!
        @shipment.private!
        @proposal = create :proposal, shipment: @shipment, price: 100.55, user: @logged_in_user
      end

      it 'should show it, and hide carrier names' do
        json_query :get, :lowest_proposal, id: @shipment.id
        expect(@json[:price]).to eq '100.55'
        expect(@json[:user]).to be nil
      end

      it 'should render 404 for non existent shipment' do
        @shipment.destroy
        json_query :get, :lowest_proposal, id: @shipment.id
        expect(@json[:error]).to eq 'not_found'
      end

      it 'should not show for other private shipment' do
        shipment = create :shipment, private_proposing: true
        shipment.auction!
        json_query :get, :lowest_proposal, id: shipment.id
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

      it 'should list and not disclose carrier names' do
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

      it 'should not list draft shipments' do

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
        shipment = create :shipment, private_proposing: true
        json_query :get, :current_proposals, id: shipment.id
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

  context 'Shipper shipments manipulations' do

    login_user

    before do
      @logged_in_user.add_role :shipper
    end

    context 'listing' do
      it 'should let shipper :index shipments' do
        shipments = create_list :shipment, 2, user: @logged_in_user
        shipment_with_bids = shipments.last
        shipment_with_bids.auction!
        create_list :proposal, 1, shipment: shipment_with_bids
        json_query :get, :index
        expect(@json[:results].size).to eq shipments.size
        # newest on top
        expect(@json[:results][0]['proposals']['avg'].to_i).to be shipment_with_bids.avg_proposal.to_i # proposals with info (not low/high/avg)
        expect(@json[:results][0]['bids_count']).to eq 1 # proposal from above
      end

      it 'should :show shipment info with proposals' do
        shipment = create :shipment, user: @logged_in_user
        shipment.auction!
        proposals = create_list :proposal, 3, shipment: shipment
        json_query :get, :show, id: shipment.id
        expect(@json[:shipper_info]).not_to eq nil
        expect(@json[:receiver_info]).not_to eq nil
        expect(@json[:id]).to eq shipment.id
        expect(@json[:proposals].size).to eq 3
        expect(@json[:proposals][0]['id']).to eq proposals.first.id
      end

      it 'should let shipper list his shipment with proposals, even not active' do
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

      it 'should not let shipper list other shipments' do
        create_list :shipment, 2
        json_query :get, :index
        expect(@json[:results].size).to eq 0
      end

    end

    context 'changes during limited statuses' do

      before do
        @shipment = create :shipment, user: @logged_in_user
        @shipment.auction!
        carrier = create :user
        carrier.add_role(:carrier)
        ship_inv = create :ship_invitation, invitee: carrier, shipment: @shipment, invitee_email: carrier.email
        @proposal = create :proposal, shipment: @shipment, price: 120, user: @logged_in_user, offered_at: 2.hours.ago, accepted_at: Time.zone.now
        @shipment.offer!
        @shipment.confirm!
        expect(ActionMailer::Base.deliveries.size).to eq 3 # New proposal, You got offer, Carrier accepted offer
        ActionMailer::Base.deliveries.clear
      end


      it 'should move to :pending from :confirmed' do
        expect {
          json_query :post, :update, id: @shipment.id, shipment: {price: 135.32}
          @shipment.reload
        }.to change(@shipment, :price)
        expect(@shipment.state).to eq :pending
        email = ActionMailer::Base.deliveries.last
        expect(email.to.first).to eq @proposal.user.email
        expect(email.subject).to eq "Shipment ID:#{@shipment.id} has been changed"
        expect(@json[:status]).to eq 'ok'
      end

      it 'should not let change during prohibited statuses' do
        @shipment.picked!
        expect {
          json_query :post, :update, id: @shipment.id, shipment: {price: 135.32}
          @shipment.reload
        }.not_to change(@shipment, :price)
        expect(ActionMailer::Base.deliveries.size).to eq 0
        expect(@json[:error]).to eq 'locked_status'
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

      it 'should let shipper create new shipment with invitations' do
        expect {
          json_query :post, :create, shipment: attrs, invitations: {emails: @invs}
          expect(InviteCarriers).to have_received(:perform_async).exactly(1).with(@json[:id], @invs)
        }.to change{Shipment.count}
        expect(Shipment.find(@json[:id]).state).to eq :proposing
        expect(@json[:secret_id]).not_to be blank?
      end

      it 'should let shipper create new shipment as draft' do
        expect {
          json_query :post, :create, shipment: attrs, state: 'draft'
        }.to change{Shipment.count}
        expect(Shipment.find(@json[:id]).state).to eq :draft
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

      it 'should not let shipper create invalid shipment' do
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

        it 'should display new proposals for check_new_proposals' do
          @shipment.auction!
          create_list :proposal, 3, shipment: @shipment
          expect(@shipment.new_proposals.count).to eq 3
          create :proposal, shipment: @shipment
          json_query :get, :check_new_proposals, id: @shipment.id
          expect(@json[:status]).to eq 1
        end

        it 'should let shipper edit its own shipment' do
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

        it 'should not let shipper save bad details' do
          expect {
            json_query :put, :update, id: @shipment.id, shipment: {price: ''}
            expect(@json[:error]).to eq 'not_saved'
            @shipment.reload
          }.not_to change(@shipment, :price)
        end

        it "should not let shipper edit someone's shipment" do
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
