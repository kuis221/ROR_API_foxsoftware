require 'active_support/core_ext'

guard 'rspec', bundler: false do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  # Rails example
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml|\.jbuilder)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/api/v1/(.+)_(controller)\.rb$})  { |m| ["spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  # watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }

  # Capybara features specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml|jbuilder)$})          { |m| "spec/features/#{m[1]}_spec.rb" }


  # Factory girl
  watch(%r{^spec/factories/(.+)\.rb$}) do |m|
    %W[
      spec/models/#{m[1].singularize}_spec.rb
      spec/controllers/v1/#{m[1]}_controller_spec.rb
      spec/requests/#{m[1]}_controller_cspec.rb
    ]
  end
end
