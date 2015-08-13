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
#  private_bidding      :boolean          default(FALSE)
#  active               :boolean          default(TRUE)
#  stackable            :boolean          default(TRUE)
#  price                :decimal(10, 2)
#  pickup_at            :datetime         not null
#  arrive_at            :datetime         not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_shipments_on_active   (active)
#  index_shipments_on_user_id  (user_id)
#

class Shipment < ActiveRecord::Base
  belongs_to :user
  belongs_to :shipper_info
  belongs_to :receiver_info
  has_many :shipment_feedbacks, dependent: :destroy

  mount_uploader :picture, ShipmentPictureUploader
  resourcify

  TRUCKLOAD_TYPES = {}

  # Used for validation here, and in swagger doc generation
  # :required or :optional for swagger !
  ATTRS = {dim_w: {desc: 'Width', required: :required, type: :double},
           dim_h: {desc: 'Height', required: :required, type: :double},
           dim_l: {desc: 'Length', required: :required, type: :double},
           distance: {desc: 'Distance in miles', required: :required, type: :integer},
           notes: {desc: 'Notes', required: :optional, type: :string},
           price: {desc: 'Price', required: :required, type: :double},
           pickup_at: {desc: 'Pickup time', required: :required, type: :datetime},
           arrive_at: {desc: 'Arrive time', required: :required, type: :datetime}
  }

  ATTRS.each_pair do |k,v|
    validates_presence_of k if v[:required] == :required
  end



  def picture_url
    picture.url
  end

  def active!
    update_attribute :active, true
  end

  def inactive!
    update_attribute :active, false
  end

end
