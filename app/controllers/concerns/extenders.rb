 module Extenders

  def limit
    @limit ||= params[:limit]||10
  end

  def page
    @page ||= params[:page]||1
  end

  def render_error(code=400, explanation='')
    logger.info "***  GOT ERROR CODE:#{code} explain:[#{explanation}]"
    render json: {error: code, text: explanation, version: Version.to_s}
  end

  def render_ok(message='')
    render json: {status: :ok, version: 'v1', message: message}
  end

  def detect_ip
    env['HTTP_X_REAL_IP'] || (
    env['HTTP_X_FORWARDED_FOR'] &&
        env['HTTP_X_FORWARDED_FOR'].split(',').first.strip
    )
  end


end