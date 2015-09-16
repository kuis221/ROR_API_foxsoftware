# == Schema Information
#
# Table name: ratings
#
#  id               :integer          not null, primary key
#  pick_on_time     :boolean
#  delivery_on_time :boolean
#  tracking_updated :boolean
#  had_claims       :boolean
#  will_recommend   :boolean
#  user_id          :integer
#  shipment_id      :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_ratings_on_shipment_id  (shipment_id)
#  index_ratings_on_user_id      (user_id)
#

FactoryGirl.define do
  factory :rating do
    shipment
    user
    pick_on_time true
    delivery_on_time true
    tracking_updated true
    had_claims false
    will_recommend true
  end

end
