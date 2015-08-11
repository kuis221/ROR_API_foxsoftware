module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      @logged_admin_user = FactoryGirl.create(:admin, confirmed_at: Time.now.utc) # Using factory girl as an example
      # in device_token_auth access-token generated only during request and not stored in db.
      @logged_admin_user.tokens = {}
      # {"access-token"=>"ei4fNcM-NaTHpAKs1PzidQ", "token-type"=>"Bearer", "client"=>"-1dihIv1u5cW9Xd9eKWptg", "expiry"=>"1440510675", "uid"=>"luigi@abbott.biz"}
      @logged_admin_user.create_new_auth_token.each_pair do |k,v|
        @request.headers[k] = v
      end
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @logged_in_user = FactoryGirl.create(:user, confirmed_at: Time.now.utc)
      # in device_token_auth access-token generated only during request and not stored in db.
      @logged_in_user.tokens = {}
      # {"access-token"=>"ei4fNcM-NaTHpAKs1PzidQ", "token-type"=>"Bearer", "client"=>"-1dihIv1u5cW9Xd9eKWptg", "expiry"=>"1440510675", "uid"=>"luigi@abbott.biz"}
      @logged_in_user.create_new_auth_token.each_pair do |k,v|
        @request.headers[k] = v
      end
    end
  end


end