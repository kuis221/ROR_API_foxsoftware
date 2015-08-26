source 'https://rubygems.org'

ruby '2.2.2'
gem 'rails', '4.2.1'
## Core components
gem 'pg'
gem 'unicorn'
gem 'versionist'
gem 'swagger-docs'
# gem 'jbuilder', '~> 2.2.16'
# gem 'oj'
gem 'sidekiq'
gem 'haml'
gem 'aasm'

# Security
gem 'rack-cors', require: 'rack/cors'
gem 'secure_headers'

## Uploads
gem 'carrierwave'
gem 'carrierwave-aws'
gem 'mini_magick'

## Authorization and roles
gem 'devise'
gem 'devise_token_auth'
gem 'cancancan'
gem 'rolify'
gem 'fb_graph2'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-linkedin-oauth2', github: 'EppO/omniauth-linkedin-oauth2'

## Addons
gem 'newrelic_rpm'
gem 'airbrake'
gem 'mailgun_rails'
gem 'open_uri_redirections'
gem 'rails_admin'
gem 'rails_config'

## Assets


group :development do
  gem 'rubycritic', require: false
  gem 'better_errors' #This catches Rails Side Errors
  gem 'binding_of_caller'
  gem 'traceroute' #find dead routes
  gem 'brakeman', require: false
  gem 'quiet_assets'
  gem 'guard'
  gem 'guard-rspec'
  gem 'colorize'
  gem 'colorized_routes'
end

group :development, :test do
  gem 'byebug'
  gem 'ffaker'
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'factory_girl_rails'
  gem 'awesome_print'
  gem 'rspec-rails'
  gem 'annotate'
  gem 'bullet'
  gem 'dotenv-rails'
end

group :test do
  gem 'simplecov', require: false
  gem 'capybara'
  gem "database_cleaner"
end