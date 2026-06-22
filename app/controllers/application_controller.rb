class ApplicationController < ActionController::Base
  include BotChallengePage::Controller
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  helper_method :current_user
  helper Openseadragon::OpenseadragonHelper
  helper ::BlacklightHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Spotlight::Controller
  
  layout 'blacklight'

  # Patch for load balancer: use HTTPS urls even when config.use_ssl is false
  def default_url_options(options={})
    Rails.env.production? ? options.merge(protocol: :https) : options
  end


end
