class Api::V1::ApiBaseController < ApplicationController

  before_action :authenticate_user!
  before_filter :check_registration

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
      [:index, :show, :create, :update, :delete].each do |api_action|
        swagger_api api_action do
          # TODO make a some first user with two shipments, bids, auth. so api doc user can see the responces
          param :header, 'access-token', :string, :required, 'Logged in user access token'
          param :header, 'uid', :string, :required, 'Logged in user UID(uid from oauth or email)'
          param :header, 'client', :string, :required, 'Cliend ID'
          if api_action == :index
            param :query, :page, :integer, :optional, 'Page', {defaultValue: 1}
            param :query, :limit, :integer, :optional, 'Results limit', {defaultValue: Settings.index_list}
          end
        end
      end
      ## Populate Response model here
      # Add models here which has ATTRS constants in it (see Shipment for details).

      [Shipment].each do |s_model|
        # because all setup_basic_api_documentation rendered for each controller
        # we make a little hack to render only models we include in [].each
        next if s_model.table_name != controller_name
        class_name = s_model.name
        attrs = "#{class_name}::ATTRS".constantize
        swagger_model class_name.to_sym do
          description "#{class_name} object"
          attrs.each_pair do |k,v|
            property k, v[:type], v[:required], v[:desc]
          end
        end
        # populate some action.
        [:create, :update].each do |action|
          swagger_api action do
            summary "#{action.to_s.upcase} #{class_name}"
            attrs.each_pair do |k,v|
              # TODO maybe it should populate allowed params ? or modify ATTRS with new property - allowed_param: true
              next if v[:for_model] # skip, if attribute is for swagger_model only
              param :form, "#{class_name.downcase}[#{k}]", v[:type], v[:required], v[:desc], {defaultValue: v[:default]}
            end
            response :ok, 'Success', class_name
            response :not_valid
          end
        end
      end
    end
  end

end
