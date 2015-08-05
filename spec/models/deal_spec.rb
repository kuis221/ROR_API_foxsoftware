# == Schema Information
#
# Table name: deals
#
#  id          :integer          not null, primary key
#  description :string
#  picture     :string
#  type_of     :string
#  quantity    :integer
#  venue_id    :integer
#  user_id     :integer
#  price       :decimal(10, 2)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_deals_on_user_id   (user_id)
#  index_deals_on_venue_id  (venue_id)
#

require 'rails_helper'

RSpec.describe Deal, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
