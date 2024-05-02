# frozen_string_literal: true
ActiveSupport::Reloader.to_prepare do
  Riiif::Image.file_resolver = Spotlight::CarrierwaveFileResolver.new

  # Riiif::Image.authorization_service = IIIFAuthorizationService

  # Riiif.not_found_image = 'app/assets/images/us_404.svg'
  #
  Riiif::Engine.config.cache_duration = 365.days

  if Rails.env.production?
    Riiif::ImagemagickCommandFactory.external_command = "gm convert"
    Riiif::ImageMagickInfoExtractor.external_command = "gm identify"
  end
end