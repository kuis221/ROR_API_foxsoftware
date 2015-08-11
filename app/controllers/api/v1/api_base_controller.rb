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
          param :header, 'access-token', :string, :required, 'Logged in user access token'
          param :header, 'uid', :string, :required, 'Logged in user UID(uid from oauth or email)'
          param :header, 'client', :string, :required, 'Cliend ID'
          if api_action == :index
            param :query, :page, :integer, :optional, 'Page, default 1'
            param :query, :limit, :integer, :optional, "Results limit, default: #{Settings.index_limit}"
          end
        end
      end
    end
  end

end
