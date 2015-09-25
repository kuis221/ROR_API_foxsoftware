is_heroku = ENV.any? {|x,_| x=~ /^dyno/i }
abort('DO NOT RUN IN PRODUCTION MODE') if Rails.env.production? && !is_heroku

require 'ffaker'
require 'factory_girl'
## Create a demo data for api documentation.
# Also swagger-ui doc folder(api-doc) js modified to use 'set_value' fields that populated by swagger, for auth.
# we store access-token into .admin_notes field so we can "remember" it for api documentation for pre-populate
## Lets go!

def create_user(email)
  user = User.new
  user.email = email
  user.first_name = FFaker::Name.first_name
  user.password = '123qweasd'
  user.password_confirmation = '123qweasd'
  user.confirmed_at = Time.now
  user.save!
  user
end

[User, Shipment, Proposal, Rating, Friendship, AddressInfo, ShipInvitation, Tracking].each {|m| m.destroy_all}

puts '--> ADDING STUFF:'
puts '-> Users with access-token'

email = "adminx@exxample.com"
unless User.exists?(email: email)
  puts '-> Create a user with admin role'
  user = create_user(email)
  user.add_role :admin
  user.add_role :user_manager
end
access_token = user.create_new_auth_token['access-token']
user.update_attribute(:admin_notes, access_token)

carrier_email = 'carrier_demo@xxxxxx.com'
# keep same email in @shipper_demo_user finding in ApiBaseController
shipper_email = 'shipper_demo@xxxxxx.com'
if User.exists?(email: carrier_email)
  carrier = User.find_by_email carrier_email
else
  carrier = create_user carrier_email
  carrier.add_role :carrier
end
access_token = carrier.create_new_auth_token['access-token']
carrier.update_attribute(:admin_notes, access_token)

if User.exists?(email: shipper_email)
  shipper = User.find_by_email shipper_email
else
  shipper = create_user shipper_email
  shipper.add_role :shipper
end
access_token = shipper.create_new_auth_token['access-token']
shipper.update_attribute(:admin_notes, access_token)

puts '-> Shipment with proposals, invitation, offered status and offered proposal'
# Just opened shipment in proposing state
shipment = FactoryGirl.create :shipment, user: shipper
# above will create shipper_info and receiver_info owned by shipper.
inv = FactoryGirl.create :ship_invitation, invitee: carrier, invitee_email: carrier_email, shipment: shipment
shipment.auction!
proposals = FactoryGirl.create_list :proposal, 2, user: carrier, shipment: shipment
proposal = proposals[1]
proposal.offered!
shipment.offer!
FactoryGirl.create_list :proposal, 3, shipment: shipment

puts '-> Completed shipment with proposal, trackings, delivered status and rating'
# Complete shipment with proposal, tracking, rating
shipment = FactoryGirl.create :shipment, user: shipper
shipment.auction!
proposal = FactoryGirl.create :proposal, user: carrier, shipment: shipment
shipment.offer!
proposal.offered!
shipment.confirm!
proposal.accepted!
shipment.picked! # eg: in in_transit state
trackings = FactoryGirl.create_list :tracking, 5, user: carrier, shipment: shipment
shipment.delivered!
rating = FactoryGirl.create :rating, user: shipper, shipment: shipment

puts '-> Friendships(eg: MyConnectionsController)'
FactoryGirl.create :friendship, friend: carrier, user: shipper
FactoryGirl.create_list :friendship, 4, user: shipper


puts '--> DONE'