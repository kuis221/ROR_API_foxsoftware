# == Schema Information
#
# Table name: shipments
#
#  id                   :integer          not null, primary key
#  notes                :string
#  picture              :string
#  secret_id            :string
#  weight               :decimal(10, 2)   default(0.0)
#  dim_w                :decimal(10, 2)   default(0.0)
#  dim_h                :decimal(10, 2)   default(0.0)
#  dim_l                :decimal(10, 2)   default(0.0)
#  distance             :integer          not null
#  n_of_cartons         :integer          default(0)
#  cubic_feet           :integer          default(0)
#  unit_count           :integer          default(0)
#  skids_count          :integer          default(0)
#  user_id              :integer
#  original_shipment_id :integer
#  hazard               :boolean          default(FALSE)
#  private_proposing    :boolean          default(FALSE)
#  active               :boolean          default(TRUE)
#  stackable            :boolean          default(TRUE)
#  price                :decimal(10, 2)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  shipper_info_id      :integer
#  receiver_info_id     :integer
#  aasm_state           :string           not null
#  auction_end_at       :datetime
#  po                   :string
#  pe                   :string
#  del                  :string
#  pickup_at_from       :datetime
#  pickup_at_to         :datetime
#  arrive_at_from       :datetime
#  arrive_at_to         :datetime
#  hide_proposals       :boolean          default(FALSE)
#  track_frequency      :string
#
# Indexes
#
#  index_shipments_on_aasm_state        (aasm_state)
#  index_shipments_on_active            (active)
#  index_shipments_on_receiver_info_id  (receiver_info_id)
#  index_shipments_on_shipper_info_id   (shipper_info_id)
#  index_shipments_on_user_id           (user_id)
#

class Shipment < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :shipper_info
  belongs_to :receiver_info

  has_many :proposals, dependent: :destroy
  has_many :ship_invitations, dependent: :destroy
  has_many :shipment_feedbacks, dependent: :destroy
  has_many :trackings, dependent: :destroy

  mount_uploader :picture, ShipmentPictureUploader
  resourcify

  scope :active, ->() {where(active: true)}
  # dont use :public name as scope name :) unless you want be deep in shit
  scope :public_only, ->() {where(private_proposing: false)}
  before_create :set_secret_id

  # Used for validation here, in swagger doc generation (for swagger_api methods and swagger_model)
  # -> :required or :optional for swagger
  # -> for_model: true > only use in swagger_model, looks like its not working as desired.
  ATTRS = {
           po: {desc: 'PO', required: :optional, type: :string},
           pe: {desc: 'PE', required: :optional, type: :string},
           del: {desc: 'Del', required: :optional, type: :string},
           dim_w: {desc: 'Width', required: :required, type: :double},
           dim_h: {desc: 'Height', required: :required, type: :double},
           dim_l: {desc: 'Length', required: :required, type: :double},
           distance: {desc: 'Distance', required: :required, type: :integer},
           notes: {desc: 'Notes', required: :optional, type: :string},
           price: {desc: 'Price', required: :required, type: :double},
           n_of_cartons: {desc: 'Number of cartons', required: :required, type: :integer},
           cubic_feet: {desc: 'Cubic feet', required: :required, type: :integer},
           unit_count: {desc: 'Unit count', required: :required, type: :integer},
           skids_count: {desc: 'Skids count', required: :required, type: :integer},
           hazard: {desc: 'Is hazard', required: :optional, type: :boolean, default: :false},
           private_proposing: {desc: 'Is private auction by link', required: :optional, type: :boolean, default: :false},
           active: {desc: 'Is active', required: :optional, type: :boolean, default: :true},
           stackable: {desc: 'Is stackable', required: :optional, type: :boolean, default: :true},
           pickup_at_from: {desc: 'Pickup time(from)', required: :required, type: :datetime},
           arrive_at_from: {desc: 'Arrive time(from)', required: :required, type: :datetime},
           pickup_at_to: {desc: 'Pickup time(to), for range', required: :optional, type: :datetime},
           arrive_at_to: {desc: 'Arrive time(to), for range', required: :optional, type: :datetime},
           original_shipment_id: {desc: 'Repeated from shipment', type: :integer, for_model: true},
           shipper_info_id: {desc: 'ShipperInfo address ID', type: :integer, required: :required},
           receiver_info_id: {desc: 'ReceiverInfo address ID', type: :integer, required: :required},
           secret_id: {desc: 'Part for private url', type: :string, for_model: true},
           auction_end_at: {desc: 'When shipment stop taking any proposals', type: :datetime, required: :required, for_model: true},
           hide_proposals: {desc: 'Hide proposals for everyone except owner', type: :boolean, default: :false, required: :optional, for_model: true},
           track_frequency: {desc: 'Required tracking frequency update, use: X.INTERVAL, like: 2.hours or 1.day ..', type: :string, required: :optional}
  }
  ATTRS.each_pair do |k,v|
    validates_presence_of k if v[:required] == :required
  end
  validates_inclusion_of :hide_proposals, in: [true, false]

  aasm do # add whiny_transitions: true to return true/false
    state :pending, initial: true
    state :proposing
    state :offered
    state :in_transit
    state :delivered
    state :completed
    state :cancelled

    event :auction do
      transitions from: :pending, to: :proposing
    end

    event :negotiation do
      transitions from: :proposing, to: :offered
    end

    event :shipped do
      transitions from: :proposing, to: :in_transit
    end

    event :reject_offer do
      transitions from: :proposing, to: :pending
    end

  end

  # should be after validates_presence_of shipper_info_id and receiver_info_id
  after_validation :validate_addresses
  # Check that associated addresses belongs to that user
  def validate_addresses
    self.errors.add(:shipper_info_id, 'bad association') unless user.shipper_info_ids.include?(shipper_info_id)
    self.errors.add(:receiver_info_id, 'bad association') unless user.receiver_info_ids.include?(receiver_info_id)
  end

  def hide_proposals!
    update_attribute :hide_proposals, true
  end

  def low_proposal
    proposals.minimum('proposals.price')
  end

  def high_proposal
    proposals.maximum('proposals.price')
  end

  def avg_proposal
    proposals.average('proposals.price')
  end

  def state
    aasm_state.to_sym
  end

  # Check if shipment create by user
  def owned_by?(some_user)
    user == some_user
  end

  # Check for:
  # -> user has not reached limit of proposals
  # -> user has invitation_for? shipment if private, or shipment active+public
  def status_for_proposing(price, user)
    status = :no_access # default if user has no invitation or not_active+public
    if user.proposals.with_shipment(id).count >= Settings.proposal_limit
      status = :limit_reached
    else
      if auction_end_at <= Time.zone.now
        status = :end_auction_date
      else
        if state != :proposing
          status = :not_in_auction
        else
          status = :ok if !user.invitation_for?(self).nil? || public_active?
        end
      end
    end
    status
  end

  def eligible_for_render?(param_secret_id, current_user)
    public_or_active?(param_secret_id) || user == current_user
  end

  def public_or_active?(param_secret_id)
    public_active? || (private_proposing? && secret_id == param_secret_id && active?)
  end

  def public_active?
    !private_proposing? && active?
  end

  def has_invitation_for?(user)
    ship_invitations.for_user(user.id).count > 0
  end

  def private!
    update_attribute :private_proposing, true
  end

  # Manage ship_invitations here. delete all when [], replace if size>0, or ignore if nil.
  # TODO maybe add 'user_ids' => [1,2,3] in future
  # invitations: {'emails' => ['email@example.com', 'email2@example.com']}
  # Also reset secret_id so "old" invitees will not get access
  def invite!(invitations = nil)
    if invitations.nil?
      # Ignore
    else # edit
      ship_invitations.each {|s| s.destroy } # Delete anyway
      emails = invitations['emails'].to_a.compact
      if emails.size > 0
        # fill new
        transaction do
          set_secret_id
          save!
          InviteCarriers.perform_async(self.id, emails)
          # ShipInvitation.invite_by_emails!(self, invitations)
        end
      end
    end
  end

  def toggle_active!
    update_attribute :active, !active?
  end

  def set_secret_id
    self.secret_id = (Shipment.last.try(:id)||0).to_s + SecureRandom.urlsafe_base64(nil, false)
  end

  def picture_url
    picture.url
  end

  def active!
    update_attribute :active, true
  end

  def inactive!
    self.active = false
    save!
  end

end
