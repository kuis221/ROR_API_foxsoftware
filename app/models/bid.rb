# == Schema Information
#
# Table name: bids
#
#  id         :integer          not null, primary key
#  seller_id  :integer
#  buyer_id   :integer
#  deal_id    :integer
#  price      :decimal(10, 2)
#  ip         :inet
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_bids_on_buyer_id   (buyer_id)
#  index_bids_on_deal_id    (deal_id)
#  index_bids_on_seller_id  (seller_id)
#

class Bid < ActiveRecord::Base
  belongs_to :seller, class_name: 'User', foreign_key: :seller_id
  belongs_to :buyer, class_name: 'User', foreign_key: :buyer_id
  belongs_to :deal

  resourcify
end
