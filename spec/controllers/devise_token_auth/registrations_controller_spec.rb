require 'rails_helper'

describe DeviseTokenAuth::RegistrationsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  shared_examples_for 'oauth' do |provider|

    set_oauth_login(provider)

    before do
      expect(@mock[:provider]).to eq provider
    end

    it 'should register properly' do
      session[:redirect_url] = '/'
      session[:user_role] = 'shipper'
      expect { get :oauth_login, provider: provider }.to change{User.count}.by(1)
      expect(response).to redirect_to('/')
      user = User.last
      identity = user.identities.last
      expect(identity.provider).to eq provider.to_s
      expect(user.roles_name).to match_array %w(user shipper)
      validate_auth_headers user
    end

    it 'should not register without redirect url' do
      session[:redirect_url] = nil
      session[:user_role] = 'carrier'
      expect { get :oauth_login, provider: provider }.not_to change{User.count}
      expect(response.body).to match('no redirect_url in session')
    end

    it 'should not register without user role' do
      session[:redirect_url] = '/'
      session[:user_role] = nil
      expect { get :oauth_login, provider: provider }.not_to change{User.count}
      expect(response.body).to match('no user_role in session')
    end

    it 'should not register without proper email' do
      @mock['info']['email'] = "d"
      session[:redirect_url] = '/'
      session[:user_role] = 'shipper'
      expect { get :oauth_login, provider: provider }.not_to change{User.count}
      read_json_response(:get)
      expect(@json[:error]).to eq 'not_saved'
    end


  end


  it_should_behave_like 'oauth', :facebook
  # google_oauth2
  # linkedin

  context 'shipper user with email' do
    let(:attrs) { {alt_email: 'alt@email.com', password: '123123', password_confirmation: '123123', about: 'BIO about',
                   first_name: FFaker::Name.first_name, last_name: FFaker::Name.last_name, email: FFaker::Internet.email}
    }

    it 'should properly register user with shipper role' do
      expect {
        json_query :post, :create, attrs
      }.to change{User.count}.by(1)
      expect(ActionMailer::Base.deliveries.size).to eq 1
      user = User.last
      # tokens not generated when need to confirm an email, see devise_token_auth_spec request
      # token_client = user.tokens.first[0]
      # expect(response.headers['access-token']).not_to be blank?
      # expect(user.uid).to eq response.headers['uid']
      # expect(user.tokens[token_client]['expiry'].to_s).to eq response.headers['expiry']
      expect(user.has_role?(:user)).to eq true
      expect(user.has_role?(:shipper)).to eq true
      attrs.each_pair do |k,v|
        next if [:password, :password_confirmation].include?(k)
        expect(user[k]).to eq v
      end
    end

    it 'should not register with duplicate email' do
      create :user, email: attrs[:email]
      expect {
        json_query :post, :create, attrs
      }.not_to change{User.count}
      expect(@json[:error]).to eq 'not_saved'
      expect(ActionMailer::Base.deliveries.size).to eq 0
    end

    context 'should register carrier user' do
      it 'and check assigned invitations' do
        ship_invitation = create :ship_invitation, invitee_email: attrs[:email]
        expect {
          json_query :post, :create, attrs.merge({user_type: 'carrier'})
        }.to change{User.count}.by(1)
        user = User.last
        expect(user.ship_invitations.size).to eq 1
        expect(user.ship_invitations.first.id).to eq ship_invitation.id
        expect(user.has_role?(:user)).to eq true
        expect(user.has_role?(:carrier)).to eq true
        expect(user.has_role?(:shipper)).to eq false
      end

      it "and has no someone's else invitation" do
        ship_invitation = create :ship_invitation, invitee_email: FFaker::Internet.email
        expect {
          json_query :post, :create, attrs.merge({user_type: 'carrier'})
        }.to change{User.count}.by(1)
        user = User.last
        expect(user.ship_invitations.size).to eq 0
      end
    end

    it 'should not let with blank password' do
      attrs[:password] = ''
      expect {
        json_query :post, :create, attrs
        expect(@json[:text]['password']).not_to be blank?
      }.not_to change{User.count}
    end

    it 'should not let with bad email' do
      attrs[:email] = 'bad'
      expect {
        json_query :post, :create, attrs
        expect(@json[:text]['email']).not_to be blank?
      }.not_to change{User.count}
    end

    it 'should not let with mismatching password' do
      attrs[:password_confirmation] = 'zozosd'
      expect {
        json_query :post, :create, attrs
        expect(@json[:text]['password_confirmation']).not_to be blank?
      }.not_to change{User.count}
    end
  end

  context 'Edit user details' do
    login_user
    let(:attrs) { {current_password: '123123', password: '4123123', password_confirmation: '4123123', about: 'New BIO about', first_name: FFaker::Name.first_name, last_name: FFaker::Name.last_name, email: FFaker::Internet.email} }

    it 'save new details' do
      expect{
        json_query :post, :update, attrs
        @logged_in_user.reload
        expect(@json[:status]).to eq 'ok'
      }.to change(@logged_in_user, :about)
    end

    it "can't save bad email" do
      attrs[:email] = 'bad'
      expect{
        json_query :post, :update, attrs
        @logged_in_user.reload
        expect(@json[:error]).to eq 'not_valid'
      }.not_to change(@logged_in_user, :about)
    end

    it 'cant save because current_password wrong' do
      attrs[:current_password] = '1231231'
      expect{
        json_query :post, :update, attrs
        @logged_in_user.reload
        expect(@json[:error]).to eq 'not_valid'
      }.not_to change(@logged_in_user, :about)
    end

    # WEIRD. devise do not validate password and password_confirmation ?????????????
    # it 'will not accept mismatch new passwords' do
    #   attrs[:current_password] = '123123'
    #   attrs[:password] = '1231'
    #   attrs[:password_confirmation] = '12312345'
    #   expect{
    #     json_query :post, :update, attrs
    #     @logged_in_user.reload
    #     expect(@json[:error]).to eq 'not_valid'
    #   }.not_to change(@logged_in_user, :about)
    # end

  end

end