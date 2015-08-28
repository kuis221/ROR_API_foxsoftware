# == Schema Information
#
# Table name: friendships
#
#  id         :integer          not null, primary key
#  friend_id  :integer
#  user_id    :integer
#  type_of    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_friendships_on_friend_id  (friend_id)
#  index_friendships_on_user_id    (user_id)
#

require 'rails_helper'

RSpec.describe Friendship, type: :model do
  # TODO add validation examples. to test client can add carrier only
end
