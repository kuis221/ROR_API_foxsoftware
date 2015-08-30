# == Schema Information
#
# Table name: trackings
#
#  id              :integer          not null, primary key
#  shipment_id     :integer
#  user_id         :integer
#  location        :string
#  notes           :text
#  checkpoint_time :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_trackings_on_shipment_id  (shipment_id)
#  index_trackings_on_user_id      (user_id)
#

require 'rails_helper'

RSpec.describe Tracking, type: :model do

end
