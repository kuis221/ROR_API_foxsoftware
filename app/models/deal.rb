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

class Deal < ActiveRecord::Base
  belongs_to :user
  belongs_to :venue

  mount_uploader :picture, DealPictureUploader
  resourcify

end
