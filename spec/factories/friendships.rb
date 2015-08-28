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

FactoryGirl.define do
  factory :friendship do
    user
    friend factory: :user
    type_of Friendship::TYPE_OF.first
  end

end
