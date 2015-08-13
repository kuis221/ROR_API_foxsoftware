# == Schema Information
#
# Table name: address_infos
#
#  id           :integer          not null, primary key
#  type         :string
#  contact_name :string           not null
#  city         :string           not null
#  zip_code     :string           not null
#  address1     :string           not null
#  address2     :string           not null
#  state        :string(2)        not null
#  appointment  :boolean          default(FALSE)
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class AddressInfo < ActiveRecord::Base
  belongs_to :user
  has_many :shipments

  validates_presence_of :city, :state, :house
end

class ShipperInfo < AddressInfo; end
class ReceiverInfo < AddressInfo; end


