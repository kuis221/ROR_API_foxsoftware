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

class UserInfo < AddressInfo
  belongs_to :user

  after_validation :validate_singularity

  def validate_singularity
    self.errors.add(:user_id, 'are already has UserInfo') if UserInfo.where(user_id: user_id).first
  end

end
