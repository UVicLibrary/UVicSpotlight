# frozen_string_literal: true

module Spotlight
  module Resources
    module UploadDecorator

      # Modified to fit file types other than images.
      def to_solr
        # return {} unless upload&.file_present?
        if self.file_type == "image"
          return image_index_fields
        else
          { Spotlight::Engine.config.thumbnail_field => ThumbnailService.new(self).create_thumbnail }
        end
      end

      def save
        self.file_name = self.upload.image.file.filename if self.compound_ids.blank?
        super
      end

      private

      def image_index_fields
        spotlight_routes = Spotlight::Engine.routes.url_helpers
        riiif = Riiif::Engine.routes.url_helpers

        dimensions = Riiif::Image.new(upload_id).info

        {
          spotlight_full_image_width_ssm: dimensions.width,
          spotlight_full_image_height_ssm: dimensions.height,
          Spotlight::Engine.config.thumbnail_field => riiif.image_path(upload, size: '!400,400'),
          Spotlight::Engine.config.iiif_manifest_field => spotlight_routes.manifest_exhibit_solr_document_path(exhibit, compound_id)
        }
      end

    end
  end
end
Spotlight::Resources::Upload.prepend(Spotlight::Resources::UploadDecorator)