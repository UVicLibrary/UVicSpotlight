class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  helper_method :current_user
  helper Openseadragon::OpenseadragonHelper
  helper ::BlacklightHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Spotlight::Controller
  # skip_after_action :discard_flash_if_xhr
  layout 'blacklight'

end
