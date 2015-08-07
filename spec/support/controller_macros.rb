module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      @logged_admin_user = FactoryGirl.create(:admin) # Using factory girl as an example
      @request.headers['access-token'] = @logged_admin_user.tokens['access-token']
      @request.headers['access-uid'] = @logged_admin_user.uid
      # sign_in @logged_admin_user
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @logged_in_user = FactoryGirl.create(:user, confirmed_at: Time.now.utc)
      @request.headers['access-token'] = @logged_in_user.tokens['access-token']
      @request.headers['access-uid'] = @logged_in_user.uid
      # sign_in @logged_in_user
    end
  end
end