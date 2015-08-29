class ApplicationController < ActionController::Base
  respond_to :json
  ensure_security_headers
  # before_filter :dummy_proof_auth_headers

  include DeviseTokenAuth::Concerns::SetUserByToken
  include Extenders

  before_filter :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound do |e|
    render_error :not_found, 404
  end

  # raise activerecord erorr or string(used from AddressInfoController)
  rescue_from ActiveRecord::RecordInvalid do |e|
    render_error :not_saved, 500, (e.is_a?(String) ? e : e.record.errors.full_messages)
  end

  rescue_from CanCan::AccessDenied do |exception|
    logger.info "ROLE DENIED DENIED: user: #{current_user.id} roles: #{current_user.roles_name}"
    render_error :access_denied_with_role, 403
  end

  private

  # def dummy_proof_auth_headers
  #   params['access-token'] = request.headers['access-token']
  #   params['uid'] = request.headers['uid']
  #   params['client'] = request.headers['client']
  # end

  protected
  def configure_permitted_parameters
    create_attrs = [:first_name, :last_name, :about, :avatar, :provider]
    update_attrs = [:first_name, :last_name, :about, :avatar]
    devise_parameter_sanitizer.for(:sign_up) << create_attrs
    devise_parameter_sanitizer.for(:account_update) << update_attrs
  end


end