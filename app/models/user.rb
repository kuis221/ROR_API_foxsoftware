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
  devise :database_authenticatable, :confirmable, :recoverable, :registerable, :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :linkedin]
  include DeviseTokenAuth::Concerns::User # after devise

  # has_many :identities, dependent: :destroy
  has_many :shipments, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_many :address_infos, dependent: :destroy
  has_many :shipper_infos, dependent: :destroy
  has_many :receiver_infos, dependent: :destroy
  # its not user created ship_invitation but from where user invited
  has_many :ship_invitations, foreign_key: :invitee_id, dependent: :destroy

  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships

  validates_presence_of :email, :first_name
  validates_presence_of :password, :password_confirmation, confirmation: true, on: :create
  validates_confirmation_of :password, on: :create

  mount_uploader :avatar, UserAvatarUploader

  scope :active, ->() {where(blocked: false)}
  scope :with_email, ->(email) {where(email: email)}

  ATTRS = {
      first_name: {desc: 'First name', required: :required, type: :string},
      last_name: {desc: 'Last name', required: :optional, type: :string},
      about: {desc: 'About', required: :optional, type: :string},
      email: {desc: 'Email', required: :required, type: :string},
      provider: {desc: 'Registration provider, email of oauth', required: :required, type: :string}
  }

  before_create -> do
    assign_user_role
  end

  # Assign all invitations to newly created user
  after_create -> do
    ShipInvitation.where(invitee_email: email).update_all(invitee_id: id)
  end

  # Return active shipment which has invitation
  # def invited_shipment(shipment_id)
  #   Shipment.active.joins(:ship_invitations).where('shipments.id = ? AND ship_invitations.invitee_id IN (?)', shipment_id, id).first
  # end

  def name
    "#{first_name} #{last_name[0].to_s.upcase}."
  end

  def invitation_for?(shipment)
    shipment ? (ship_invitations.where(shipment_id: shipment.id).first && shipment.active?) : nil
  end

  # by default all users get :user role. second role  depends on params[:user_type]
  def assign_role_by_param(user_type)
    role = :client
    role = :carrier if user_type == 'carrier'
    add_role role
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
