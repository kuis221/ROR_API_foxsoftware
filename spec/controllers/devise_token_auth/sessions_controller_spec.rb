require 'rails_helper'

describe DeviseTokenAuth::SessionsController, type: :controller do

  context 'logout user' do
    login_user

    it do
      expect {
        json_query :delete, :destroy
        @logged_in_user.reload
      }.to change(@logged_in_user, :tokens)
      expect(@json[:status]).to eq 'ok'
    end
  end

end