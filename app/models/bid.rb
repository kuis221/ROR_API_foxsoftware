# == Schema Information
#
# Table name: bids
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  shipment_id :integer
#  price       :decimal(10, 2)
#  ip          :inet
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_bids_on_shipment_id  (shipment_id)
#  index_bids_on_user_id      (user_id)
#

class Bid < ActiveRecord::Base
  belongs_to :user
  belongs_to :shipment

  scope :with_shipment, ->(shipment_id) {where(shipment_id: shipment_id)}
  scope :by_highest, ->() {order('bids.price DESC')}
  scope :by_lowest, ->() {order('bids.price ASC')}

  resourcify

  # Do not use it here
  # ATTRS = {
  #     price: {desc: 'Price', required: :required, type: :double},
  #     shipment_id: {desc: 'Shipment ID', required: :required, type: :integer}
  # }

  validates_presence_of :price, :shipment_id, :equipment_type
  after_validation :validate_shipment

  # Check that associated shipment has ship invitation
  def validate_shipment
    self.errors.add(:shipment_id, 'has no invitation for current user (Bid model)') if shipment.try(:private_bidding?) && user.invitation_for?(shipment).blank?
    self.errors.add(:shipment_id, 'is in invalid state for bidding') unless shipment.try(:bidding?)
  end
end
