require 'rails_helper'

describe DeviseTokenAuth::RegistrationsController, type: :request do

  context 'client user with email' do
    let(:attrs) { {password: '123123', password_confirmation: '123123', about: 'BIO about', first_name: FFaker::Name.first_name, last_name: FFaker::Name.last_name, email: FFaker::Internet.email} }

    it 'should create and confirm user' do
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
      token_client = user.tokens.first[0]
      expect(response.headers['access-token']).not_to be blank?
      expect(user.uid).to eq response.headers['uid']
      expect(user.tokens[token_client]['expiry'].to_s).to eq response.headers['expiry']
    end

  end

  context 'client user with oauth' do
    let(:attrs) { {provider: 'facebook', about: 'BIO about', first_name: FFaker::Name.first_name, last_name: FFaker::Name.last_name, email: FFaker::Internet.email} }
    # TODO, write oauth test
  end

end