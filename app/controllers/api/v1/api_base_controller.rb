class Api::V1::ApiBaseController < ApplicationController

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
          # or :query
          param :header, 'access-token', :string, :required, 'Logged in user access token'
          param :header, 'access-uid', :string, :required, 'Logged in user UID'
        end
      end
    end
  end

end
