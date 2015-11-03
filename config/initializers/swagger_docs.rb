# class Swagger::Docs::Config
#     def self.transform_path(path, api_version)
#         # Make a distinction between the APIs and API documentation paths.
#         "api-docs/#{path}"
#     end
# end

module Swagger
    module Docs
        class Config
            class << self
                # Extend stuff to generate docs for heroku, because heroku does not let save local files and you have
                # to do it locally and push :-( with:
                # rake swagger:docs FOR=heroku
                # or without FOR arg to create local
                def extract_for_host
                    for_env = ARGV[1].split('=') rescue false
                    # TODO change later to some ENV
                    return 'http://foxsoftware-staging.herokuapp.com' if for_env && for_env[0] == 'FOR' && for_env[1] == 'heroku'
                end
            end
        end
    end
end

class Swagger::Docs::Config
    def self.transform_path(path, api_version)
        "#{Swagger::Docs::Config.extract_for_host||Settings.host}/apidocs/#{path}"
    end
end
Swagger::Docs::Config.register_apis({
    '1.0' => {
        # the extension used for the API
        api_extension_type: :json,
        # the output location where your .json files are written to
        api_file_path: "public/apidocs",
        # the URL base path to your API
        base_path: Swagger::Docs::Config.extract_for_host||Settings.host,
        # controller_base_path: '',
        # if you want to delete all .json files at each generation
        clean_directory: true,
        # base_api_controllers: [ApplicationController],
        # add custom attributes to api-docs
        camelize_model_properties: false,
        attributes: {
            info: {
                "title" => "Fox LMP",
                # "description" => "Shipment network",
                "contact" => "cat.of.duty@gmail.com"
            }
        }
    }
})