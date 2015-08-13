# == Schema Information
#
# Table name: shipments
#
#  id             :integer          not null, primary key
#  description    :string
#  picture        :string
#  weight         :decimal(10, 2)   default(0.0)
#  dim_w          :decimal(10, 2)   default(0.0)
#  dim_h          :decimal(10, 2)   default(0.0)
#  dim_l          :decimal(10, 2)   default(0.0)
#  distance       :integer          not null
#  user_id        :integer
#  truckload_type :integer
#  hazard         :boolean          default(FALSE)
#  active         :boolean          default(TRUE)
#  price          :decimal(10, 2)
#  pickup_at      :datetime         not null
#  arrive_at      :datetime         not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_shipments_on_truckload_type  (truckload_type)
#  index_shipments_on_user_id         (user_id)
#

FactoryGirl.define do
  factory :shipment do
    notes FFaker::Lorem.words(2).join(' ')
    dim_w {FFaker.numerify("##.##")}
    dim_h {FFaker.numerify("##.##")}
    dim_l {FFaker.numerify("##.##")}
    distance {FFaker.numerify("####")}
    weight {FFaker.numerify("##.##")}
    user
    price {FFaker.numerify("###.##")}
    pickup_at 20.hours.from_now
    arrive_at 40.hours.from_now
    stackable true
    n_of_cartons {rand(10)}
    cubic_feet {rand(10)}
    unit_count {rand(10)}
    skids_count {rand(10)}
  end

end
