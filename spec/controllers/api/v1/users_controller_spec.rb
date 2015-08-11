require 'rails_helper'

describe Api::V1::UsersController, type: :controller do

  context 'Signed in user' do

    login_user

    it 'should return not blocked user' do
      user = create :user, blocked: false
      json_query :get, :show, id: user.id
      expect(@json[:id]).to eq user.id
    end

    it 'should not render blocked user' do
      user = create :user, blocked: true
      json_query :get, :show, id: user.id
      expect(response.status).to eq 404
    end

    it 'should deny access to blocked user' do
      @logged_in_user.block!
      user = create :user, blocked: false
      json_query :get, :show, id: user.id
      expect(@json[:error]).to eq 'user_not_valid_or_blocked'
    end
  end

  context 'Unregistered visitor' do

    it 'should deny user access' do
      user = create :user, blocked: false
      json_query :get, :show, id: user.id
      expect(@json[:errors].size).to eq 1
    end
  end

end
