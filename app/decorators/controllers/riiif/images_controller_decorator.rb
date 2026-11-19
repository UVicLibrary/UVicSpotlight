# frozen_string_literal: true

# OVERRIDE riiif v.2.8.1
# Rescue Vips::Error with 400 response
module Riiif
  module ImagesControllerDecorator

    def show
      begin
        super
      rescue Vips::Error
        render plain: "Requested region is outside image area", status: 400
      rescue ArgumentError
        Rails.logger.warn "ArgumentError: request uri = #{request.uri}"
        raise
      end
    end

  end
end
Riiif::ImagesController.prepend(Riiif::ImagesControllerDecorator)