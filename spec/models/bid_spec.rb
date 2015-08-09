# == Schema Information
#
# Table name: bids
#
#  id           :integer          not null, primary key
#  seller_id    :integer
#  buyer_id     :integer
#  commodity_id :integer
#  price        :decimal(10, 2)
#  ip           :inet
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_bids_on_buyer_id      (buyer_id)
#  index_bids_on_commodity_id  (commodity_id)
#  index_bids_on_seller_id     (seller_id)
#

require 'rails_helper'

RSpec.describe Bid, type: :model do
end
