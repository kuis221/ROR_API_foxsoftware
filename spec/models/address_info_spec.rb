# == Schema Information
#
# Table name: address_infos
#
#  id               :integer          not null, primary key
#  type             :string
#  city             :string           not null
#  street           :string           not null
#  state            :string(2)        not null
#  user_id          :integer
#  home_number      :integer
#  apartment_number :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe AddressInfo, type: :model do
end
