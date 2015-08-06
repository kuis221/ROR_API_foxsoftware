class ApplicationController < ActionController::Base

  ensure_security_headers

  before_filter :check_registration
  before_filter :configure_permitted_parameters, if: :devise_controller?

  include Extenders
  respond_to :json

  rescue_from CanCan::AccessDenied do |exception|
    render_error :access_denied
    head 403
  end

  private

  def check_registration
    if current_user && (!current_user.valid? || !current_user.approved?)
      render_error :not_approved
      head 403
    end
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :about) }
  end

end
