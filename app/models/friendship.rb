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

class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: 'User'
  # Type of friendship relation - client has many carriers or carrier has many clients
  TYPE_OF = %w(client carrier) # do not change order of array

  scope :clients, ->() {where(type_of: TYPE_OF.first)}
  scope :carriers, ->() {where(type_of: TYPE_OF.last)}

  validates :type_of, inclusion: TYPE_OF
  validates_presence_of :user_id, :friend_id
end
