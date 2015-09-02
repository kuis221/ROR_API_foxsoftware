module Extenders

  def validate_role(role)
    raise CanCan::AccessDenied unless current_user.has_role?(role)
  end

  def limit
    @limit ||= params[:limit]||Settings.index_list
  end

  def page
    @page ||= params[:page]||1
  end

  def render_error(code=400, status = 200, explanation='')
    logger.info "***  GOT ERROR CODE:#{code} explanation:#{explanation}]  user:#{current_user.try(:id)}"
    render json: {error: code, text: explanation, version: $current_api_version}, status: status
  end

  def render_ok(message='')
    render json: {status: :ok, version: $current_api_version, message: message}
  end

  # Render JSON from a single AR object or and array/relation, from presenters according to object class
  # Return inline string or render json directly
  def render_json(object, inline=false, with_pagination: true)
    if object.is_a?(Array) || object.is_a?(ActiveRecord::Relation)
      json = []
      object.each do |obj|
        json << render_single_object(obj, :index)
      end
      # This will add class as root json
      # object.first.class.table_name
      json = {results: json}
      json.merge!({page: page, limit: limit}) if with_pagination
    else
      json = render_single_object(object, :show)
    end
    inline ? json : (render json: json)
  end

  def render_single_object(object, object_type)
    klass = "Api::#{$current_api_version}::#{object.class}Presenter".constantize
    klass.minimal_hash(object, current_user, object_type)
  end

  def detect_ip
    env['HTTP_X_REAL_IP'] || (
    env['HTTP_X_FORWARDED_FOR'] &&  env['HTTP_X_FORWARDED_FOR'].split(',').first.strip
    )
  end

  def check_registration
    if current_user && current_user.blocked?
      render_error :user_not_valid_or_blocked, 403
    end
  end
end