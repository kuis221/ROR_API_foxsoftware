class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def all
    identity = Identity.from_omniauth(request.env["omniauth.auth"])
    user = identity.find_or_create_user(current_user)

    if user.valid?
      sign_in user
      render_ok
    else
      render_error :invalid_oauth
    end
  end

  alias_method :facebook, :all
  alias_method :google_oauth2, :all
  alias_method :linkedin, :all
end