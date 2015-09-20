module OmniAuthLogin

  # stub omniauth requests
  def set_oauth_login(provider, opts={})
    before do
      OmniAuth.config.test_mode = true
      default = { uid: rand(1000)+1000,
                 provider => {
                     email: 'mockup@example.com',
                     gender: 'Male',
                     first_name: 'Mocked',
                     # image: 'http://1.bp.blogspot.com/_7ZYqYi4xigk/SWfANhA5U9I/AAAAAAAACOM/-8e3TJyR0zA/s320/Google+Favicon_0109.png',
                     last_name: 'User'
                 }
      }
      # Add google_oauth2 and linkedin
      credentials = default.merge(opts)
      user_hash = credentials[provider]

       @mock = OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new({
          'uid' => credentials[:uid],
          'provider' => provider,
          'credentials' => {
              'token' => 'token',
              'secret' => 'secret'
          },
          'info' => user_hash,
          'extra' => {
              'raw_info' => user_hash
          }
      })
      OmniAuth.config.add_mock(provider, @mock)
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @request.env["omniauth.auth"] = @mock
    end
  end

  def set_invalid_login(opts = {})
    before do
      credentials = { :provider => :facebook,
                      :invalid  => :invalid_crendentials
      }.merge(opts)
      OmniAuth.config.mock_auth[credentials[:provider]] = credentials[:invalid]
    end
  end

end