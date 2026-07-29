require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Exhibits
  class Application < Rails::Application

    # Since Rails 6/7, the new autoloader, Zeitwerk, will eagerload any dir in app.
    # However, we don't want to eagerload our decorators just yet, since Spotlight and
    # other gems need to be loaded before we load our decorators.
    Rails.autoloaders.main.ignore(Rails.root.join('app/decorators'))

    config.to_prepare do
      # Now we load decorator files
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")).sort.each do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    # Since Rails 7
    config.load_defaults 7.0
    config.autoloader = :zeitwerk

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Setting English and Chinese to be the only available languages
    config.i18n_locales = {
      zh: 'Chinese',
      en: 'English'
    }
  end
  
end

