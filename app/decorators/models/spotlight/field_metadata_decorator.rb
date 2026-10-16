module Spotlight
  module FieldMetadataDecorator

    # OVERRIDE Spotlight v.4.7.0: Show query facet fields, such as Object Type
    def facet_fields
      blacklight_config.facet_fields.reject { |_k, v| v.pivot }
    end

  end
end
Spotlight::FieldMetadata.prepend(Spotlight::FieldMetadataDecorator)