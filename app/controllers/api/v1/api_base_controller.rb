class Api::V1::ApiBaseController < ApplicationController

  before_action :authenticate_user!
  before_filter :check_registration

  # :nocov:
  # Use that with unconventional listing actions
  def self.add_pagination_params(api)
    api.param :query, :page, :integer, :optional, 'Page', {defaultValue: 1}
    api.param :query, :limit, :integer, :optional, 'Results limit', {defaultValue: Settings.index_list}
  end

  # User details
  def self.generic_user_details(api)
    api.param :form, :first_name, :string, :required, 'First Name'
    api.param :form, :last_name, :string, :required, 'Last Name'
    api.param :form, :email, :string, :required, 'Email'
    api.param :form, :alt_email, :string, :optional, 'Alternative email'
    api.param :form, :password, :string, :required, 'Password'
    api.param :form, :password_confirmation, :string, :required, 'Password confirmation'
    api.param :form, :about, :string, :optional, 'About me'
    api.param :form, :mc_num, :string, :optional, 'MC number'
  end

  # Reuse that method in custom actions, those are out side of regular crud
  def self.add_authorization_headers(api)
    # TODO make a some first user with two shipments, proposals, auth. so api doc user can see the responses
    @shipper_demo_user ||= User.where(email: 'shipper_demo@xxxxxx.com').first # Keep same in seeds
    # .admin_notes field contain one time generated access-token
    api.param :header, 'access-token', :string, :required, 'Logged in user access token', {defaultValue: @shipper_demo_user.try(:admin_notes)}
    api.param :header, 'uid', :string, :required, 'Logged in user UID(uid from oauth or email)', {defaultValue: @shipper_demo_user.try(:uid)}
    api.param :header, 'client', :string, :required, 'Cliend ID', {defaultValue: (@shipper_demo_user ? @shipper_demo_user.tokens.keys.first : '')}
  end

  # do not put code between nocov tags
  class << self
    Swagger::Docs::Generator::set_real_methods
    def inherited(subclass)
      super
      subclass.class_eval do
        setup_basic_api_documentation
      end
    end
    private
    # called for each controller
    def setup_basic_api_documentation
      # Add authorization headers for all default actions
      [:index, :show, :create, :update, :delete].each do |api_action|
        swagger_api api_action do |api|
          Api::V1::ApiBaseController.add_authorization_headers(api)
          Api::V1::ApiBaseController.add_pagination_params(api) if api_action == :index # Pagination auto-added for all indexes
        end
      end
      ## Populate Response model here
      # Add models here which has ATTRS constants in it (see Shipment for details).

      [Shipment, AddressInfo, Tracking, Rating].each do |s_model|
        # because all setup_basic_api_documentation rendered for each controller
        # we make a little hack to render only models we include in [].each
        next if s_model.table_name != controller_name
        class_name = s_model.name
        attrs = "#{class_name}::ATTRS".constantize
        # Render a Response Model here
        swagger_model class_name.to_sym do
          description "#{class_name} object"
          attrs.each_pair do |k,v|
            property k, v[:type], v[:required], v[:desc]
          end
        end
        # populate some action for posting forms.
        [:create, :update].each do |action|
          swagger_api action do
            summary "#{action.to_s.upcase} #{class_name}"
            attrs.each_pair do |k,v|
              # TODO maybe it should populate allowed params ? or modify ATTRS with new property - allowed_param: true
              next if v[:for_model] # skip, if attribute is for swagger_model only, looks like it DOESNT really works
              param :form, "#{s_model.table_name.singularize}[#{k}]", v[:type], v[:required], v[:desc], {defaultValue: v[:default]}
            end
            response 'ok', "{#{class_name}Object}", class_name.to_sym
            response 'not_valid', "'text': [ArrayOfErrors]"
          end
        end
      end
    end
  end
  # :nocov:

end
