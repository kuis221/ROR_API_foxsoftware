# == Schema Information
#
# Table name: identities
#
#  id         :integer          not null, primary key
#  uid        :string
#  provider   :string
#  token      :string
#  secret     :string
#  email      :string
#  avatar_url :string
#  nickname   :string
#  first_name :string
#  last_name  :string
#  expires_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_identities_on_uid_and_provider  (uid,provider)
#

class Identity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :uid, :provider, :token, :email
  validates_format_of :email, with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  def self.from_omniauth(auth)
    identity = where(provider: auth.provider, uid: auth.uid).first_or_create do |identity|
      identity.provider     = auth.provider
      identity.uid          = auth.uid
      identity.token        = auth.credentials.token
      identity.secret       = auth.credentials.secret if auth.credentials.secret
      identity.expires_at   = auth.credentials.expires_at if auth.credentials.expires_at
      identity.email        = auth.info.email if auth.info.email
      identity.avatar_url   = auth.info.image if auth.info.image
      identity.first_name   = auth.info.first_name
      identity.last_name    = auth.info.last_name
    end
    identity.save!

    if !identity.persisted?
      {errors: identity.errors}
    end
    identity
  end

  def find_or_create_user(current_user=nil)
    if current_user && self.user == current_user
      # User logged in and the identity is associated with the current user
      return self.user
    elsif current_user && self.user != current_user
      # User logged in and the identity is not associated with the current user
      # so lets associate the identity and update missing info
      self.user = current_user
      self.user.email       ||= self.email
      self.user.remote_avatar_url      ||= self.avatar_url # unless user.avatar.file.exists?
      self.user.first_name  ||= self.first_name
      self.user.last_name   ||= self.last_name
      self.user.skip_reconfirmation!
      self.user.save!
      self.save!
      return self.user
    elsif self.user.present?
      # User not logged in and we found the identity associated with user
      # so let's just log them in here
      return self.user
    else
      # No user associated with the identity so we need to create a new one
      # Because we have step forward from impossibility of devise_token_auth to use many omniauth providers
      # -> we always must set user.uid to email so we can use login properly (uid set in headers)
      # -> and set provider to oauth to be more meanful in queries(for email its set 'email')
      self.build_user(
          uid: self.email,
          provider: 'oauth',
          email: self.email,
          remote_avatar_url: self.avatar_url,
          first_name: self.first_name,
          last_name: self.last_name
      )
      self.user.save!(validate: false)
      self.save!
      return self.user
    end
  end

end
