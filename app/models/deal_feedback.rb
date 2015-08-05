# == Schema Information
#
# Table name: deal_feedbacks
#
#  id          :integer          not null, primary key
#  type_of     :string
#  description :string
#  user_id     :integer
#  deal_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_deal_feedbacks_on_deal_id  (deal_id)
#  index_deal_feedbacks_on_user_id  (user_id)
#

class DealFeedback < ActiveRecord::Base
  resourcify
  belongs_to :user
  belongs_to :deal

  validates_presence_of :description
end
