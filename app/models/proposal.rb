# == Schema Information
#
# Table name: proposals
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  shipment_id    :integer
#  price          :decimal(10, 2)
#  ip             :inet
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  equipment_type :string
#  offered_at     :datetime
#  accepted_at    :datetime
#  rejected_at    :datetime
#
# Indexes
#
#  index_proposals_on_shipment_id  (shipment_id)
#  index_proposals_on_user_id      (user_id)
#

class Proposal < ActiveRecord::Base
  include ProposalAdmin
  belongs_to :user
  belongs_to :shipment

  scope :with_shipment, ->(shipment_id) {where(shipment_id: shipment_id)}
  scope :by_highest, ->() {order('proposals.price DESC')}
  scope :by_lowest, ->() {order('proposals.price ASC')}
  scope :from_user, ->(user) {where('proposals.user_id = ?', user.id)}
  scope :latest, ->() { order('proposals.created_at DESC') }
  # return any proposal that still in active mode(offered or accepted)
  scope :active, -> { where('(accepted_at IS NOT NULL OR offered_at IS NOT NULL) AND rejected_at IS NULL') }

  resourcify
  delegate :name, to: :user, prefix: true

  after_create :new_notification
  # Do not use it here
  # ATTRS = {
  #     price: {desc: 'Price', required: :required, type: :double},
  #     shipment_id: {desc: 'Shipment ID', required: :required, type: :integer}
  # }

  validates_presence_of :price, :shipment_id, :equipment_type
  after_validation :validate_shipment

  # Check that associated shipment has:
  # -> ship invitation
  # -> is in correct state
  def validate_shipment
    self.errors.add(:shipment_id, 'has no invitation for current user (Proposal model)') if shipment.try(:private_proposing?) && user.invitation_for?(shipment).blank?
    self.errors.add(:shipment_id, 'is in invalid state for proposing') unless shipment.try(:propose_allowed?)
  end

  # offered by shipper
  def offered!
    update_attribute :offered_at, Time.zone.now
  end

  # confirmed by carrier
  def accepted!
    update_attribute :accepted_at, Time.zone.now
  end

  # reject proposal by carrier. shipment should be valid for rejection (method .can_be_rejected?)
  def reject!
    shipment.rejected!
    update_attribute :rejected_at, Time.zone.now
    ShipperMailer.proposal_rejected(self).deliver_now
  end

  def new_notification
    ShipperMailer.new_proposal(self).deliver_now
  end

end
