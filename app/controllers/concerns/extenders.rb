 module Extenders

  def limit
    @limit ||= params[:limit]||10
  end

  def page
    @page ||= params[:page]||1
  end

  def render_error(code=400, status = 200, explanation='')
    logger.info "***  GOT ERROR CODE:#{code} explain:[#{explanation}]"
    render json: {error: code, text: explanation, version: $current_api_version}, status: status
  end

  def render_ok(message='')
    render json: {status: :ok, version: $current_api_version, message: message}
  end

  def render_json(object)
    klass = "Api::#{$current_api_version}::#{object.class}Presenter".constantize
    render json: klass.minimal_hash(object)
  end

  def detect_ip
    env['HTTP_X_REAL_IP'] || (
    env['HTTP_X_FORWARDED_FOR'] &&
        env['HTTP_X_FORWARDED_FOR'].split(',').first.strip
    )
  end


end