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

  # raise activerecord error or string(used from AddressInfoController)
  rescue_from ActiveRecord::RecordInvalid do |e|
    render_error :not_saved, 500, (e.is_a?(String) ? e : e.record.errors.full_messages)
  end

  rescue_from CanCan::AccessDenied do |exception|
    logger.info "ROLE DENIED DENIED: user: #{current_user.try(:id)} roles: #{current_user.try(:roles_name)}"
    respond_to do |f|
      f.html  { render text: 'To access admin please login as an admin' }
      f.json { render_error :access_denied_with_role, 403 }
    end
  end

  rescue_from MissingParam do |e|
    render_error 'missing_param', 401, e.message
  end

  private

  # def set_auth_headers
  #   response.headers['access-token'] = request.headers['access-token']
  #   response.headers['uid'] = request.headers['uid']
  #   response.headers['client'] = request.headers['client']
  # end
  # def dummy_proof_auth_headers
  #   params['access-token'] = request.headers['access-token']
  #   params['uid'] = request.headers['uid']
  #   params['client'] = request.headers['client']
  # end

  protected
  def configure_permitted_parameters
    create_attrs = [:first_name, :last_name, :about, :avatar, :provider, :mc_num, :alt_email]
    update_attrs = [:first_name, :last_name, :about, :avatar, :mc_num, :alt_email]
    devise_parameter_sanitizer.for(:sign_up) << create_attrs
    devise_parameter_sanitizer.for(:account_update) << update_attrs
  end


end