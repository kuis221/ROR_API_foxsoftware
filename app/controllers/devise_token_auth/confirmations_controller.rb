module DeviseTokenAuth
  class ConfirmationsController < DeviseTokenAuth::ApplicationController

    def show
      @resource = resource_class.confirm_by_token(params[:confirmation_token])
      if @resource and @resource.id

        # create client id
        # @client_id  = SecureRandom.urlsafe_base64(nil, false)
        # @token      = SecureRandom.urlsafe_base64(nil, false)
        # token_hash = BCrypt::Password.create(token)
        # expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

        # @resource.tokens[client_id] = {
        #     token:  token_hash,
        #     expiry: expiry
        # }
        # @resource.save! validate: false # skip passwords
        # response.headers.merge!(@resource.build_auth_header(token, client_id))

        yield if block_given?

        # See also SetUserByToken#update_auth_header with 'return true'  line, i disabled it to prevent
        # -> regeneration of after_action :update_headers callback and token regeneration if change_headers_on_each_request is false
        auth_header = @resource.create_new_auth_token
        response.headers.merge!(auth_header)

        render_json(@resource)
      else
        raise ActiveRecord::RecordNotFound
      end
    end

  end
end