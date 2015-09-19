# == Schema Information
#
# Table name: trackings
#
#  id              :integer          not null, primary key
#  shipment_id     :integer
#  user_id         :integer
#  location        :string
#  notes           :text
#  checkpoint_time :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_trackings_on_shipment_id  (shipment_id)
#  index_trackings_on_user_id      (user_id)
#

FactoryGirl.define do
  factory :tracking do
    shipment
    user
    location {"#{FFaker::Geolocation.lat}, #{FFaker::Geolocation.lng}" }
    notes { FFaker::Lorem.word }
    checkpoint_time 1.minute.ago
  end

end
