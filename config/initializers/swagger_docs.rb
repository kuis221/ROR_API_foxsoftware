# class Swagger::Docs::Config
#     def self.transform_path(path, api_version)
#         # Make a distinction between the APIs and API documentation paths.
#         "api-docs/#{path}"
#     end
# end

class Swagger::Docs::Config
    def self.transform_path(path, api_version)
        "http://localhost:3000/apidocs/#{path}"
    end
end
Swagger::Docs::Config.register_apis({
    '1.0' => {
        # the extension used for the API
        api_extension_type: :json,
        # the output location where your .json files are written to
        api_file_path: "public/apidocs",
        # the URL base path to your API
        base_path: 'http://localhost:3000',
        # controller_base_path: '',
        # if you want to delete all .json files at each generation
        clean_directory: true,
        # base_api_controllers: [ApplicationController],
        # add custom attributes to api-docs
        camelize_model_properties: false,
        attributes: {
            info: {
                "title" => "Fox Software",
                # "description" => "Commodity network",
                "contact" => "cat.of.duty@gmail.com"
            }
        }
    }
})