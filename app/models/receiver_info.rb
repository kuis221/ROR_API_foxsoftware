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
#  state        :string(2)        not null
#  appointment  :boolean          default(FALSE)
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  is_default   :boolean          default(FALSE)
#  address2     :string
#  title        :string
#  fax          :string
#  company_name :string
#
# Indexes
#
#  index_address_infos_on_is_default  (is_default)
#

# STI
class ReceiverInfo < AddressInfo
  has_one :shipment
  belongs_to :user
end


