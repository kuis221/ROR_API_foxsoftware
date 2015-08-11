# == Schema Information
#
# Table name: commodities
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
#  index_commodities_on_truckload_type  (truckload_type)
#  index_commodities_on_user_id         (user_id)
#

require 'rails_helper'

RSpec.describe Commodity, type: :model do
end
