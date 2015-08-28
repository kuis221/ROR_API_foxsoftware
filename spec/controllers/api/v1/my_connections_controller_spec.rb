require 'rails_helper'

# Actually its all about Friendship model.
RSpec.describe Api::V1::MyConnectionsController, type: :controller do
  # Test twice for each role
  [:client, :carrier].each do |user_role|
    login_user

    context "[#{user_role.to_s.upcase}] connections" do

      before do
        @logged_in_user.add_role(user_role) # User will get user_role, so we have to create opposite friendships
      end

      it 'should display all' do
        connections = create_list :friendship, 3, user: @logged_in_user, type_of: opposite_role(user_role)
        json_query :get, :index
        expect(@json[:results].size).to eq 3
        @json[:results].each do |fs|
          expect(connections.map(&:friend_id)).to include fs['friend']['id']
          expect(connections.map(&:friend).map(&:name)).to include fs['friend']['name']
        end
      end

      it 'should find one' do
        connection = create :friendship, user: @logged_in_user, type_of: opposite_role(user_role)
        json_query :get, :show, id: connection.id
        expect(@json[:id]).to eq connection.id
      end

      it 'should not find other user connection' do
        connection = create :friendship, type_of: opposite_role(user_role)
        json_query :get, :show, id: connection.id
        expect(@json[:error]).to eq 'not_found'
      end

      it 'should create properly' do
        friend = create :user
        friend.add_role(user_role)
        json_query :post, :create, {friend_id: friend.id}
        expect(@json[:friend]['name']).to eq friend.name
      end

      it 'should not create without user_id' do
        json_query :post, :create
        expect(@json[:error]).to eq 'not_saved'
      end

      if user_role == :client
        before do
          @shipment = create :shipment, user: @logged_in_user
          @emails = []
          5.times{|e| @emails << FFaker::Internet.email }
        end

        it 'should invite carriers' do
          expect {
            json_query :post, :invite_carrier, shipment_id: @shipment.id, emails: @emails
          }.to change{ShipInvitation.count}.by(5)
          expect(@json[:message]).to eq 5
          expect(ActionMailer::Base.deliveries.size).to eq 5
        end

        it 'should not invite with wrong email' do
          @emails << 'bademail'
          expect {
            json_query :post, :invite_carrier, shipment_id: @shipment.id, emails: @emails
          }.not_to change{ShipInvitation.count}
          expect(ActionMailer::Base.deliveries.size).to eq 0
        end

        it 'should not invite without shipment_id' do
          expect {
            json_query :post, :invite_carrier, emails: @emails
          }.not_to change{ShipInvitation.count}
          expect(ActionMailer::Base.deliveries.size).to eq 0
        end

        it 'should not invite with someone else shipment_id' do
          shipment = create :shipment
          expect {
            json_query :post, :invite_carrier, shipment_id: shipment.id, emails: @emails
          }.not_to change{ShipInvitation.count}
          expect(ActionMailer::Base.deliveries.size).to eq 0
        end

      else

        it 'should not let carrier invite_carrier' do
          expect {
            json_query :post, :invite_carrier
          }.not_to change{ShipInvitation.count}
          expect(@json[:error]).to eq 'access_denied_with_role'
          expect(ActionMailer::Base.deliveries.size).to eq 0
        end

      end
    end

  end

  def opposite_role(role)
    role == :client ? :carrier : :client
  end
end
