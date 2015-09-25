# == Schema Information
#
# Table name: ratings
#
#  id               :integer          not null, primary key
#  pick_on_time     :boolean
#  delivery_on_time :boolean
#  tracking_updated :boolean
#  had_claims       :boolean
#  will_recommend   :boolean
#  user_id          :integer
#  shipment_id      :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_ratings_on_shipment_id  (shipment_id)
#  index_ratings_on_user_id      (user_id)
#

class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :shipment

  rails_admin do
    exclude_fields :updated_at
  end

  ATTRS = {
      pick_on_time: {desc: 'Pickup On-time?', required: :required, type: :boolean},
      delivery_on_time: {desc: 'Delivery On-time?', required: :required, type: :boolean},
      tracking_updated: {desc: 'Tracking Updates provided as requested?', required: :required, type: :boolean},
      had_claims: {desc: 'Did you have any claims?', required: :required, type: :boolean},
      will_recommend: {desc: 'Would you recommend this carrier?', required: :required, type: :boolean},
      shipment_id: {desc: 'Shipment ID', required: :required, type: :string}
  }.freeze

  validates_presence_of :shipment_id, :user_id

  ATTRS.each_pair do |k,v|
    validates_inclusion_of k, in: [true, false] if v[:required] == :required && v[:type] == :boolean
  end

  after_validation :validate_shipment_status, on: :create
  after_create :notify_carrier

  def can_be_updated?
    Date.today < created_at + Settings.edit_rating_due.days
  end

  # Only :delivering status can create rating
  def validate_shipment_status
    self.errors.add(:shipment_id, 'is in invalid state for rating') if !shipment || !shipment.may_closed? #cant closed
  end

  # notify carrier about received rating and set status
  def notify_carrier
    shipment.closed!
    CarrierMailer.rating_received(self).deliver_now
  end
end
