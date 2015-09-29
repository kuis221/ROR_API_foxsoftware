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
#  mc_num                 :string
#  alt_email              :string
#  admin_notes            :string
#
# Indexes
#
#  index_users_on_blocked               (blocked)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

FactoryGirl.define do

  factory :user do
    email {FFaker::Internet.email}
    first_name {FFaker::Name.first_name}
    last_name {FFaker::Name.last_name}
    password '123123'
    password_confirmation '123123'
    after :create do |user|
      user.add_role :user
      user.create_new_auth_token
    end

    trait :confirmed do
      confirmed_at Time.now
    end
  end

  factory :admin, parent: :user do
    after :create do |user|
      user.add_role :admin
    end
  end

  factory :carrier, parent: :user do
    after :create do |user|
      user.add_role :carrier
    end
  end

  factory :shipper, parent: :user do
    after :create do |user|
      user.add_role :shipper
    end
  end


end
