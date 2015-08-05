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
#  nickname               :string
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
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable, :recoverable, :rememberable, :trackable
  devise :database_authenticatable, :omniauthable, :recoverable, :confirmable, :registerable, :rememberable, omniauth_providers: [:google_oauth2, :facebook]

  has_many :identities, dependent: :destroy
  has_many :deals
  has_many :bids
  has_many :venues, foreign_key: :created_by_user_id

  mount_uploader :avatar, UserAvatarUploader
  has_paper_trail

  before_create :assign_user_role
  #
  def assign_user_role
    self.add_role Settings.default_role
  end

  def admin?
    has_role?(:admin)
  end

  #
  # def roles=(roles)
  #   self.roles_mask = (roles & Settings.roles).map { |r| 2**Settings.roles.index(r) }.inject(0, :+)
  # end
  #
  # def roles
  #   AppConfig.roles.reject do |r|
  #     ((roles_mask || 0) & 2**Settings.roles.index(r)).zero?
  #   end
  # end
  #
  # def has_role?(role)
  #   roles.include?(role.to_s)
  # end
  #
  # # Role Inheritance
  # def role?(base_role)
  #   Settings.roles.index(base_role.to_s) <= Settings.roles.index(role)
  # end

end
