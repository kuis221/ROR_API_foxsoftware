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

  context 'browsing commodities' do

    it 'should let authorized carrier to read invited shipment' do

    end

    ## TODO check with Matt about permitting carriers to look on any commodity/shipment
    it "should not let carrier read someone's shipment" do

    end

    it 'should not let client read other commodities' do

    end

    it 'should let client list its commodities' do

    end

  end

  context 'Commodity manipulating' do

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
