# == Schema Information
#
# Table name: address_infos
#
#  id           :integer          not null, primary key
#  type         :string
#  contact_name :string           not null
#  city         :string           not null
#  zip_code     :string           not null
#  address1     :string           not null
#  address2     :string           not null
#  state        :string(2)        not null
#  appointment  :boolean          default(FALSE)
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :address_info do
    # type {%w(ShipperInfo ReceiverInfo).sample}
    contact_name {FFaker::Conference.name}
    city {FFaker::Address.city}
    address1 {FFaker::Address.street_address}
    zip_code {FFaker::AddressUS.state_abbr}
    state {FFaker::AddressUS.state_abbr}
    appointment true
    user
  end

  factory :shipper_info, parent: :address_info do
    type 'ShipperInfo'
  end

  factory :receiver_info, parent: :address_info do
    type 'ReceiverInfo'
  end
end
