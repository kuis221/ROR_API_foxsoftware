# == Schema Information
#
# Table name: commodities
#
#  id             :integer          not null, primary key
#  description    :string
#  picture        :string
#  distance       :integer          not null
#  user_id        :integer
#  truckload_type :integer
#  price          :decimal(10, 2)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_commodities_on_truckload_type  (truckload_type)
#  index_commodities_on_user_id         (user_id)
#

require 'rails_helper'

RSpec.describe Commodity, type: :model do
end
