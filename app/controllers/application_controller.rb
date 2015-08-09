class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Extenders

  respond_to :json
  ensure_security_headers
  before_filter :check_registration
  before_filter :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound do |e|
    render_error :not_found, 404
  end

  rescue_from CanCan::AccessDenied do |exception|
    logger.info 'ROLE DENIED DENIED;0'
    render_error :access_denied_with_role, 403
  end

  private

  def check_registration
    if current_user && (!current_user.valid? || current_user.blocked?)
      render_error :not_valid_or_blocked, 403
      head 403
    end
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :about, :avatar) }
  end

end
