# == Schema Information
#
# Table name: commodities
#
#  id             :integer          not null, primary key
#  description    :string
#  picture        :string
#  dim_w          :decimal(10, 2)
#  dim_h          :decimal(10, 2)
#  dim_l          :decimal(10, 2)
#  distance       :integer          not null
#  weight         :integer          not null
#  user_id        :integer
#  truckload_type :integer
#  hazard         :boolean          default(FALSE)
#  price          :decimal(10, 2)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_commodities_on_truckload_type  (truckload_type)
#  index_commodities_on_user_id         (user_id)
#

class Commodity < ActiveRecord::Base
  belongs_to :user
  belongs_to :address_info
  has_many :commodity_feedbacks, dependent: :destroy

  mount_uploader :picture, CommodityPictureUploader
  resourcify

  TRUCKLOAD_TYPES = {}
  validates_presence_of :dim_w, :dim_h, :dim_l, :distance, :description, :price, :pickup_at, :arrive_at

end
