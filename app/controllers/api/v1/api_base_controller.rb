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
    def setup_basic_api_documentation
      [:index, :show, :create, :update, :delete].each do |api_action|
        swagger_api api_action do
          param :header, 'access-token', :string, :required, 'Logged in user access token', {set_value: "see TODO"}
          param :header, 'uid', :string, :required, 'Logged in user UID(uid from oauth or email)'
          param :header, 'client', :string, :required, 'Cliend ID'
          if api_action == :index
            param :query, :page, :integer, :optional, 'Page, default 1'
            param :query, :limit, :integer, :optional, "Results limit, default: #{Settings.index_list}"
          end
        end
      end
      ## Populate Response model here
      # Add models here which has ATTRS constants in it (see Commodity for details).
      [Commodity].each do |s_model|
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
              param :form, "#{class_name.downcase}[#{k}]", v[:type], v[:required], v[:desc]
            end
            response :ok, 'Success', class_name
            response :not_acceptable
          end
        end
      end
    end
  end

end
