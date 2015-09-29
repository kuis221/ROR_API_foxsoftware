require 'rails_helper'

describe DeviseTokenAuth::SessionsController, type: :request do

  it 'should login user' do # /auth/sign_in
    user = create :shipper, :confirmed
    post '/auth/sign_in', email: user.email, password: '123123'
    read_json_response(:post)
    validate_auth_headers(user)
  end

  it 'do not login unconfirmed' do
    user = create :shipper
    post '/auth/sign_in', email: user.email, password: '123123'
    read_json_response(:post)
    expect(@json[:error]).to eq 'not_confirmed'
  end

  it 'should not login with bad password' do
    user = create :shipper, :confirmed
    post '/auth/sign_in', email: user.email, password: '12312'
    read_json_response(:post)
    expect(@json[:error]).to eq 'bad_credentials'
  end

end