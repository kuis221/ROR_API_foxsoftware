# == Schema Information
#
# Table name: address_infos
#
#  id               :integer          not null, primary key
#  type             :string
#  city             :string
#  street           :string
#  user_id          :integer
#  home_number      :integer
#  apartment_number :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe AddressInfo, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
