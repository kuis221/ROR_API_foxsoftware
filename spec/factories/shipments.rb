# == Schema Information
#
# Table name: shipments
#
#  id                   :integer          not null, primary key
#  notes                :string
#  picture              :string
#  secret_id            :string
#  weight               :decimal(10, 2)   default(0.0)
#  dim_w                :decimal(10, 2)   default(0.0)
#  dim_h                :decimal(10, 2)   default(0.0)
#  dim_l                :decimal(10, 2)   default(0.0)
#  distance             :integer          not null
#  n_of_cartons         :integer          default(0)
#  cubic_feet           :integer          default(0)
#  unit_count           :integer          default(0)
#  skids_count          :integer          default(0)
#  user_id              :integer
#  original_shipment_id :integer
#  hazard               :boolean          default(FALSE)
#  private_bidding      :boolean          default(FALSE)
#  active               :boolean          default(TRUE)
#  stackable            :boolean          default(TRUE)
#  price                :decimal(10, 2)
#  pickup_at            :datetime         not null
#  arrive_at            :datetime         not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  shipper_info_id      :integer
#  receiver_info_id     :integer
#
# Indexes
#
#  index_shipments_on_active            (active)
#  index_shipments_on_receiver_info_id  (receiver_info_id)
#  index_shipments_on_shipper_info_id   (shipper_info_id)
#  index_shipments_on_user_id           (user_id)
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
    before :create do |shipment| # should be before creation to pass validations of model
      shipper_info = create :shipper_info, user: shipment.user
      receiver_info = create :receiver_info, user: shipment.user
      shipment.receiver_info_id = receiver_info.id
      shipment.shipper_info_id = shipper_info.id
    end
  end

end
