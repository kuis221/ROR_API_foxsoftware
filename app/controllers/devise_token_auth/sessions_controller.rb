module DeviseTokenAuth
  class SessionsController < DeviseTokenAuth::ApplicationController
    before_filter :set_user_by_token, only: [:destroy]
    after_action :reset_session, only: [:destroy]

    # :nocov:
    swagger_controller :sessions, 'Email login resource'
    swagger_api :create do
      summary 'LOGIN with email'
      param :query, :email, :string, :required, 'Email'
      param :query, :password, :string, :required, 'Password'
      param :query, :remember_me, :string, :optional, 'Remember user for two weeks, (true/false)'
      response 'ok', "{'data': {}}"
      response 'not_confirmed'
      response 'bad_credentials'
    end
    # :nocov:
    def create # login
      # Check
      field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first

      @resource = nil
      if field
        q_value = resource_params[field]

        if resource_class.case_insensitive_keys.include?(field)
          q_value.downcase!
        end

        q = "#{field.to_s} = ? AND provider='email'"

        if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
          q = "BINARY " + q
        end

        @resource = resource_class.where(q, q_value).first
      end

      if @resource and valid_params?(field, q_value) and @resource.valid_password?(resource_params[:password]) and (!@resource.respond_to?(:active_for_authentication?) or @resource.active_for_authentication?)
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @resource.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
        }
        @resource.save

        sign_in(:user, @resource, store: false, bypass: false)
        auth_headers = @resource.build_auth_header(@token, @client_id)

        yield if block_given?

        response.headers.merge!(auth_headers)
        render_ok

      elsif @resource and not (!@resource.respond_to?(:active_for_authentication?) or @resource.active_for_authentication?)
        render_error 'not_confirmed', 401
      else
        render_error 'bad_credentials', 401
      end
    end

    def destroy
      # remove auth instance variables so that after_filter does not run
      user = remove_instance_variable(:@resource) if @resource
      client_id = remove_instance_variable(:@client_id) if @client_id
      remove_instance_variable(:@token) if @token

      if user and client_id and user.tokens[client_id]
        user.tokens.delete(client_id)
        user.save!

        yield if block_given?

        render_ok
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    def valid_params?(key, val)
      resource_params[:password] && key && val
    end

    def resource_params
      params.permit(devise_parameter_sanitizer.for(:sign_in))
    end

    def get_auth_params
      auth_key = nil
      auth_val = nil

      # iterate thru allowed auth keys, use first found
      resource_class.authentication_keys.each do |k|
        if resource_params[k]
          auth_val = resource_params[k]
          auth_key = k
          break
        end
      end

      # honor devise configuration for case_insensitive_keys
      if resource_class.case_insensitive_keys.include?(auth_key)
        auth_val.downcase!
      end

      return {
        key: auth_key,
        val: auth_val
      }
    end
  end
end
