# == Schema Information
#
# Table name: proposals
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  shipment_id    :integer
#  price          :decimal(10, 2)
#  ip             :inet
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  equipment_type :string
#
# Indexes
#
#  index_proposals_on_shipment_id  (shipment_id)
#  index_proposals_on_user_id      (user_id)
#

FactoryGirl.define do
  factory :proposal do
    price {FFaker.numerify("##.##")}
    equipment_type {FFaker::NatoAlphabet.callsign}
    user
    shipment
  end

end
