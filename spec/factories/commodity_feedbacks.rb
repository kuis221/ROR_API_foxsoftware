# == Schema Information
#
# Table name: commodity_feedbacks
#
#  id           :integer          not null, primary key
#  description  :string
#  rate         :integer          not null
#  user_id      :integer
#  commodity_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_commodity_feedbacks_on_commodity_id  (commodity_id)
#  index_commodity_feedbacks_on_user_id       (user_id)
#

FactoryGirl.define do
  factory :commodity_feedback do
    
  end

end
