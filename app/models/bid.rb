# == Schema Information
#
# Table name: bids
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  shipment_id :integer
#  price       :decimal(10, 2)
#  ip          :inet
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_bids_on_shipment_id  (shipment_id)
#  index_bids_on_user_id      (user_id)
#

class Bid < ActiveRecord::Base
  belongs_to :user
  belongs_to :shipment

  resourcify
end
