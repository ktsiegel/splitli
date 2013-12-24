require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rack/ssl-enforcer'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module KathrynsiegelSylvantsaiAvogelProj3
  class Application < Rails::Application
    config.middleware.use Rack::SslEnforcer, :except_environments => 'development'
  end
end
