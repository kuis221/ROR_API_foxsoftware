# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string
#  first_name             :string
#  last_name              :string
#  about                  :string
#  avatar                 :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  blocked                :boolean          default(FALSE), not null
#  provider               :string           default("email"), not null
#  uid                    :string           default(""), not null
#  tokens                 :json
#
# Indexes
#
#  index_users_on_blocked               (blocked)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable, :recoverable, :rememberable, :trackable
  # , omniauth_providers: [:google_oauth2, :facebook]
  devise :database_authenticatable, :recoverable, :registerable, :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :linkedin]
  include DeviseTokenAuth::Concerns::User # after devise

  # has_many :identities, dependent: :destroy
  has_many :shipments, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_many :address_infos, dependent: :destroy

  validates_presence_of :email
  validates_presence_of :password, :password_confirmation, confirmation: true
  validates_confirmation_of :password

  mount_uploader :avatar, UserAvatarUploader

  scope :active, ->() {where(blocked: false)}
  scope :with_email, ->(email) {where(email: email)}

  before_create -> do
    assign_user_role
    # skip_confirmation!
  end

  def assign_user_role
    self.add_role Settings.default_role
  end

  def admin?
    has_role?(:admin)
  end

  def client?
    has_role?(:client)
  end

  def carrier?
    has_role?(:carrier)
  end

  def active_for_authentication?
    super && !blocked?
  end

  def inactive_message
    if blocked?
      :blocked
    else
      super # Use whatever other message
    end
  end

  def block!
    update_attribute :blocked, true
  end
end
