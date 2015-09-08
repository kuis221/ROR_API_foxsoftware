require 'rails_helper'

RSpec.describe Api::V1::AddressInfosController, type: :controller do
  login_user
  let(:attrs) { {state: 'CA', zip_code: '20860', city: 'Palm Springs', address1: 'Lake street 21', fax: '112233', company_name: FFaker::Company.name,
                 appointment: true, contact_name: 'Alex', type: 'ShipperInfo', is_default: false, title: 'Zooloo'} }

  shared_examples_for 'create address_info' do |address_type| # eg: ShipperInfo
    it 'normally' do
      expect {
        attrs[:type] = address_type
        json_query :post, :create, address_info: attrs
        expect(@json[:type]).to eq address_type
      }.to change{address_type.constantize.count}.by(1)
      expect(@logged_in_user.send(address_type.constantize.table_name).count).to eq 1
    end
  end

  context 'CRUD AddressInfo' do

    it_should_behave_like 'create address_info', 'ShipperInfo'
    it_should_behave_like 'create address_info', 'ReceiverInfo'
    it_should_behave_like 'create address_info', 'UserInfo'

    it 'should load my_address' do
      user_info = create :user_info, user: @logged_in_user
      json_query :get, :my_address
      expect(@json[:id]).to eq user_info.id
    end

    it 'load some address_info' do
      shipper_info = create :shipper_info, user: @logged_in_user
      json_query :get, :show, id: shipper_info.id
      expect(@json[:id]).to eq shipper_info.id
      expect(@json[:type]).to eq 'ShipperInfo'
    end

    it 'should not let create UserInfo twice' do
      user_info = create :user_info, user: @logged_in_user
      attrs[:type] = 'UserInfo'
      expect {
        json_query :post, :create, address_info: attrs
        expect(@json[:error]).to eq 'not_saved'
      }.not_to change{UserInfo}
    end

    it 'should not create with bad type' do
      attrs[:type] = 'shipperInfo'
      expect {
        json_query :post, :create, address_info: attrs
        expect(@json[:error]).to eq 'not_saved'
      }.not_to change{ShipperInfo}
    end

    it 'should not create without required detail' do
      attrs[:state] = ''
      expect {
        json_query :post, :create, address_info: attrs
        expect(@json[:error]).to eq 'not_saved'
      }.not_to change{ShipperInfo}
    end

    context 'Updates' do
      before do
        @receiver_info = create :receiver_info, user: @logged_in_user
      end

      it 'should update address' do
        expect {
          json_query :patch, :update, id: @receiver_info.id, address_info: {city: 'Los Angeles'}
          @receiver_info.reload
        }.to change(@receiver_info, :city)
      end

      it 'should change type' do
        expect {
          json_query :patch, :update, id: @receiver_info.id, address_info: {type: 'ShipperInfo'}
          @receiver_info.reload
        }.to change(@receiver_info, :type)
      end

      it 'should not update invalid type' do
        expect {
          json_query :patch, :update, id: @receiver_info.id, address_info: {type: 'shipperInfo'}
          @receiver_info.reload
        }.to raise_error ActiveRecord::SubclassNotFound
      end

      it 'should not update with bad details' do
        expect {
          json_query :patch, :update, id: @receiver_info.id, address_info: {city: ''}
          @receiver_info.reload
        }.not_to change(@receiver_info, :city)
      end

      it 'should destroy it' do
        expect{
          json_query :delete, :destroy, id: @receiver_info.id
        }.to change{ReceiverInfo.count}.by(-1)
      end
    end
  end

  context 'Setting default addresses for shipper' do
    before do
      ## main to change
      @receiver_info = create :receiver_info, user: @logged_in_user
      @shipper_info = create :shipper_info, user: @logged_in_user
      ## to test for remain unchanged
      @receivers = create_list :receiver_info, 3, user: @logged_in_user # false, false, true
      @receiver_default = @logged_in_user.receiver_infos.last
      @receiver_default.default!

      @shippers = create_list :shipper_info, 3, user: @logged_in_user # false, false, true
      @shipper_default = @logged_in_user.shipper_infos.last
      @shipper_default.default!
    end

    it 'should load all addresses' do
      json_query :get, :index
      expect(@json[:results].size).to eq 8
    end

    it 'should load default addresses' do
      expect(@receiver_default.is_default?).to eq true
      expect(@shipper_default.is_default?).to eq true
      json_query :get, :my_defaults
      expect(@json[:shipper_info]['id']).to eq @shipper_default.id
      expect(@json[:receiver_info]['id']).to eq @receiver_default.id
    end

    context 'set_as_default_receiver' do
      it 'should set default' do
        expect(@receiver_info.is_default?).to be false
        expect {
          json_query :post, :set_as_default_receiver, id: @receiver_info.id
          @receiver_info.reload
        }.to change(@receiver_info, :is_default)
        expect(@receiver_default.reload.is_default?).to be false
      end

      # Nothing should be changed here from before filter
      it 'cant change default of other address class' do
        expect {
          json_query :post, :set_as_default_receiver, id: @shipper_info.id
          expect(@json[:error]).to eq 'not_valid'
          @receiver_info.reload
        }.not_to change(@receiver_info, :is_default)
        expect(@shipper_info.is_default?).to eq false
        expect(@receiver_default.is_default?).to be true
        expect(@shipper_default.is_default?).to be true
      end
    end

    context 'set_as_default_shipper' do
      it 'should set default' do
        expect(@shipper_info.is_default?).to be false
        expect {
          json_query :post, :set_as_default_shipper, id: @shipper_info.id
          @shipper_info.reload
        }.to change(@shipper_info, :is_default)
        expect(ShipperInfo.where(id: @shippers.map(&:id)).pluck(:is_default).uniq).to eq [false]
      end

      it 'cant change default of other address class' do
        expect {
          json_query :post, :set_as_default_shipper, id: @receiver_info.id
          expect(@json[:error]).to eq 'not_valid'
          @shipper_info.reload
        }.not_to change(@shipper_info, :is_default)
        expect(@receiver_info.is_default?).to eq false
        expect(@shipper_default.is_default?).to be true
        expect(@receiver_default.is_default?).to be true
      end

    end

  end
end
