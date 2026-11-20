# frozen_string_literal: true

# OVERRIDE riiif v.2.8.1
# Rescue Vips::Error with 400 response
module Riiif
  module ImagesControllerDecorator

    def show
      begin
        super
      rescue Vips::Error, ArgumentError
        Rails.logger.warn "ArgumentError: request uri = #{request.path}"
        render plain: "Invalid image request", status: 400
      rescue Riiif::ImageNotFoundError
        render status: 404, plain: 'Not Found'
      end
    end

  end
end
Riiif::ImagesController.prepend(Riiif::ImagesControllerDecorator)