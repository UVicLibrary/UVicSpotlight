# frozen_string_literal: true
#
Spotlight::RiiifService.class_eval do
  # iiif_service module for when using the built-in riiif server
    # @param [Spotlight::FeaturedImage] image
    # @return [String]
    def self.info_url(image, _host = nil)
      Riiif::Engine.routes.url_helpers.info_path(image)
    end
end