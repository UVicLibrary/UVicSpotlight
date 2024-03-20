require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Exhibits
  class Application < Rails::Application

    # config.active_record.yaml_column_permitted_classes = [ActiveSupport::HashWithIndifferentAccess, Symbol]
    # config.assets.initialize_on_precompile = true

    config.to_prepare do
      # Allows us to use decorator files
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")).sort.each do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.after_initialize do
      # Psych Allow YAML Classes
      # config.active_record.yaml_column_permitted_classes = [Symbol, Hash, Array, ActiveSupport::HashWithIndifferentAccess, ActiveModel::Attribute.const_get(:FromDatabase), Time]
    end

        # config.action_mailer.default_url_options = { host: "mail", from: "noreply@example.com" }
    # Initialize configuration defaults for originally generated Rails version.
    # config.load_defaults 5.2
    config.load_defaults 6.0
    config.autoloader = :zeitwerk
    # config.autoloader = :classic

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

