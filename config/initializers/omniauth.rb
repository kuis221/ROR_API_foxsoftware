Rails.application.config.middleware.use OmniAuth::Builder do
  # Linkedin fields: https://developer.linkedin.com/documents/profile-fields

  provider :linkedin,      ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], fields: ['id', 'email-address', 'first-name', 'last-name', 'picture-urls::(original)', 'public-profile-url']
  provider :facebook,      ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  provider :google_oauth2, ENV['GOOGLE_KEY'],   ENV['GOOGLE_SECRET']

end