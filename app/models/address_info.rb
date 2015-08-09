# == Schema Information
#
# Table name: address_infos
#
#  id               :integer          not null, primary key
#  type             :string
#  city             :string           not null
#  street           :string           not null
#  state            :string(2)        not null
#  user_id          :integer
#  home_number      :integer
#  apartment_number :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class AddressInfo < ActiveRecord::Base
  belongs_to :user
  has_many :commodities

  validates_presence_of :city, :state, :house
end

class ShipperInfo < AddressInfo; end
class ReceiverInfo < AddressInfo; end


