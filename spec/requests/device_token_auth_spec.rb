require 'rails_helper'

describe DeviseTokenAuth::RegistrationsController, type: :request do

  context 'shipper user with email' do
    let(:attrs) { {password: '123123', password_confirmation: '123123', about: 'BIO about', first_name: FFaker::Name.first_name, last_name: FFaker::Name.last_name, email: FFaker::Internet.email} }

    it 'should create and confirm shipper user' do
      expect { post '/auth', attrs}.to change{User.count}.by(1)
      expect(ActionMailer::Base.deliveries.size).to eq 1
      user = User.last
      expect(user.email).to eq attrs[:email]
      expect(user.confirmed?).to eq false

      body = ActionMailer::Base.deliveries.last.body.raw_source
      confirmation_token = body[/confirmation_token=([^"]+)/, 1].split('&')[0]
      confirm_url = "/auth/confirmation?config=default&confirmation_token=#{confirmation_token}&redirect_url=#{DeviseTokenAuth.default_confirm_success_url}"
      get confirm_url # confirm it !!
      expect(response).to have_http_status(200)
      user.reload
      expect(user.confirmed?).to eq true
      validate_auth_headers(user)
    end

    # this complex flow represent user:
    # -> clicking a link in invitation email (send by shipper user)
    # -> register without confirmation
    # -> attach ship_invitation
    # -> can browse private shipment
    # -> can proposal on it

    ## TODO maybe split that to examples and test both fail and success, or test inside ??
    context 'carrier flow' do
      before do
        @carrier_email = FFaker::Internet.email
      end

      it 'should do it' do
        ## Initialization
        shipper = create :shipper
        shipment = create :shipment, user: shipper, private_proposing: true
        ship_inv = create :ship_invitation, shipment: shipment, invitee_email: @carrier_email
        shipment.auction!
        CarrierMailer.send_invitation(shipment, @carrier_email).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        body = ActionMailer::Base.deliveries.last.body.raw_source
        expect(body).to include 'You has been invited to private auction on shipment'
        # <a href=\"http://localhost:3000/shipments/581?invitation=0YyuOMaO9BlJlbrEbIWHNXw\">http://localhost:3000/shipments/581?invitation=0YyuOMaO9BlJlbrEbIWHNXw</a>
        # Anyway nokogiri included by some gem dependencies..
        url = Nokogiri.HTML(body).search('a').map{ |a| a['href'] }.first
        invitation_code = url[/invitation=([^"]+)/, 1]
        expect(invitation_code).to eq shipment.secret_id
        ActionMailer::Base.deliveries.clear

        ## Registration
        attrs[:email] = @carrier_email
        expect { post '/auth', attrs.merge({invitation: invitation_code})}.to change{User.count}.by(1)
        read_json_response :post
        expect(ActionMailer::Base.deliveries.size).to eq 0 # not need for invitation code
        user = User.last
        expect(user).to eq ship_inv.reload.invitee
        expect(user.email).to eq attrs[:email]
        expect(user.confirmed?).to eq true
        expect(user.has_role?(:carrier)).to eq true
        validate_auth_headers user
        expect(@json[:first_name]).to eq attrs[:first_name]

        # Create auth headers
        @request.env["devise.mapping"] = Devise.mappings[:user]
        headers = {}
        user.create_new_auth_token.each_pair do |k,v|
          headers[k] = v
        end

        ## Show private shipment
        get "/api/v1/shipments/#{shipment.id}", {invitation: invitation_code}, headers
        read_json_response :get
        expect(@json[:error]).to be nil
        expect(@json[:id]).to eq shipment.id

        ## Proposal on it
        expect { post '/api/v1/proposals', {proposal: {price: 109.32, shipment_id: shipment.id, equipment_type: 'C130'}}, headers }.to change{Proposal.count}.by(1)
        read_json_response :post
        expect(@json[:status]).to eq 'ok'
        proposal = Proposal.last
        expect(proposal.user).to eq user
        expect(proposal.shipment).to eq shipment

        ## TODO more ? like proposal listing
      end

      # it 'goes wrong' do
      #   pending
      # end
    end
  end

  context 'shipper user with oauth' do
    let(:attrs) { {provider: 'facebook', about: 'BIO about', first_name: FFaker::Name.first_name, last_name: FFaker::Name.last_name, email: FFaker::Internet.email} }
    # TODO, write oauth test
  end

  def validate_auth_headers(user)
    token_client = user.tokens.first[0]
    expect(response.headers['access-token']).not_to be blank?
    expect(user.uid).to eq response.headers['uid']
    # dont test with last ms, because its can vary by 1 ms depends on your machine speed
    expect(user.tokens[token_client]['expiry'].to_s[0..8]).to eq response.headers['expiry'].to_s[0..8]
  end
end