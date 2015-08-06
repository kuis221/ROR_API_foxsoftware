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
#  ip                     :inet
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
#  approved               :boolean          default(FALSE), not null
#
# Indexes
#
#  index_users_on_approved              (approved)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable, :recoverable, :rememberable, :trackable
  # , omniauth_providers: [:google_oauth2, :facebook]
  devise :database_authenticatable, :recoverable, :registerable, :rememberable

  has_many :deals
  has_many :bids

  mount_uploader :avatar, UserAvatarUploader

  scope :active, ->() {where(approved: true)}

  before_create :assign_user_role
  # after_create :send_admin_mail # IF approved? are in use

  def assign_user_role
    self.add_role Settings.default_role
  end

  def admin?
    has_role?(:admin)
  end


  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    if !approved?
      :not_approved
    else
      super # Use whatever other message
    end
  end

  def send_admin_mail
    # AdminMailer.new_user_waiting_for_approval(self).deliver
  end
end
