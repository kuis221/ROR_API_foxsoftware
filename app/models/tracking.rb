# == Schema Information
#
# Table name: trackings
#
#  id              :integer          not null, primary key
#  shipment_id     :integer
#  user_id         :integer
#  location        :string
#  notes           :text
#  checkpoint_time :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_trackings_on_shipment_id  (shipment_id)
#  index_trackings_on_user_id      (user_id)
#

class Tracking < ActiveRecord::Base
  belongs_to :shipment
  belongs_to :user # carrier

  scope :for_shipment, ->(shipment) { where(shipment_id: shipment.id) }
  scope :by_newest, ->() { order('trackings.created_at DESC') }

  ATTRS = {
      location: {desc: 'Location free text', required: :required, type: :string},
      checkpoint_time: {desc: 'When arrived at this position', required: :required, type: :datetime},
      notes: {desc: 'Notes', required: :optional, type: :text},
      shipment_id: {desc: 'Shipment ID', required: :required, type: :integer}
  }

  ATTRS.each_pair do |k,v|
    validates_presence_of k if v[:required] == :required
  end

  after_validation :validate_shipment_status, on: :create
  after_create :notify_client

  # can add tracking only when in in_transit state
  def validate_shipment_status
    self.errors.add(:shipment_id, 'is in invalid state for tracking') if shipment.try(:state) != :in_transit
  end

  # send email to shipper about new tracking
  def notify_client
    ShipperMailer.new_tracking(self).deliver_now
  end
end
