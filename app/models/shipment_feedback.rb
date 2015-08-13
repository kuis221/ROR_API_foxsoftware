# == Schema Information
#
# Table name: shipment_feedbacks
#
#  id          :integer          not null, primary key
#  description :string
#  rate        :integer          not null
#  user_id     :integer
#  shipment_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_shipment_feedbacks_on_shipment_id  (shipment_id)
#  index_shipment_feedbacks_on_user_id      (user_id)
#

class ShipmentFeedback < ActiveRecord::Base
  resourcify
  belongs_to :user
  belongs_to :shipment

  validates_presence_of :description
end
