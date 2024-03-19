# encoding: utf-8
Spotlight::Resources::Upload.class_eval do

  # Modified to fit file types other than images.
  def to_solr
    # return {} unless upload&.file_present?
    if self.file_type == "image"
      return image_index_fields
    else
      # spotlight_routes = Spotlight::Engine.routes.url_helpers
      {
        # Spotlight::Engine.config.iiif_manifest_field => spotlight_routes.manifest_exhibit_solr_document_path(exhibit, compound_id),
        Spotlight::Engine.config.thumbnail_field => ThumbnailService.new(self).create_thumbnail
      }
    end
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