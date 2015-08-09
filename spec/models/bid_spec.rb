# == Schema Information
#
# Table name: bids
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  commodity_id :integer
#  price        :decimal(10, 2)
#  ip           :inet
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_bids_on_commodity_id  (commodity_id)
#  index_bids_on_user_id       (user_id)
#

require 'rails_helper'

RSpec.describe Bid, type: :model do
end
