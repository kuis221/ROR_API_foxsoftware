require 'rails_helper'

describe Api::V1::UsersController do

  describe 'Signed in user' do

    login_user

    it 'should return not blocked user' do
      user = create :user, blocked: false
      # json_query :get, :show, id: user.id
      get :show, id: user.id, format: :json
      read_json_response(:get)
      expect(@json[:id]).to eq user.id
    end

    it 'should not return blocked user' do
      user = create :user, blocked: true
      json_query :get, :show, id: user.id
      expect(response.status).to eq 404
    end

  end

end
