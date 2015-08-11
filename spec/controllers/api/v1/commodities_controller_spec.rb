require 'rails_helper'

describe Api::V1::CommoditiesController do

  before do
    @user = create :user
    @commodity = create :commodity, user: @user
  end

  context 'unauthorized browsing' do

    it 'should not let visitors read commodity(ies)' do
      json_query :get, :show, id: @commodity.id
      expect(@json[:errors].size).to eq 1
    end
  end

  context 'Carrier browsing commodities' do

    login_user

    before do
      @logged_in_user.add_role :carrier
    end

    it 'should let authorized carrier to read invited shipment' do
      # TODO Check with Matt, if way by invited commodity or ANY commodity upon inv'
    end

    it 'should not let carrier see inactive commodities' do

    end

    it "should not let carrier read someone's shipment" do
      ## TODO check with Matt about permitting carriers to look on any commodity/shipment
    end

  end

  context 'Client commodities manipulations' do

    login_user

    before do
      @logged_in_user.add_role :client
    end

    context 'listing' do
      it 'should let client list its commodities' do
        create_list :commodity, 2, user: @logged_in_user
        json_query :get, :index
        expect(@json[:results].size).to eq 2
        expect(@json[:results].first['active']).to eq true
      end

      it 'should not let client list other commodities' do
        create_list :commodity, 2
        json_query :get, :index
        expect(@json[:results].size).to eq 0
      end
    end

    it 'should let client edit its own commodity' do

    end

    it "should not let client edit someone's commodity" do

    end

    it 'should delete commodity' do

    end

    it 'should make inactive commodity' do

    end
  end

end
