module Etl
  module CustomTransforms
    # Add custom indexing fields to this file. Don't forget to add new transforms
    # to the Spotlight initializer!
    #
    #   data - the index document that is eventually pushed to Solr
    #   pipeline.source - the resource object, call pipeline.source.sidecar['data'] to get
    #                     metadata entered into the edit form

    AddFileTypeTransform = lambda do |data, pipeline|
      data.merge({ 'resource_file_type_ssi' => pipeline.source.file_type })
    end

    Add3DModelIdTransform = lambda do |data, pipeline|
      return data unless pipeline.source.model_id.present?
      data.merge({ 'spotlight_upload_3d_model_id_tesim' => pipeline.source.model_id },
                 { 'thumbnail_url_ssm' => ThumbnailService.new(pipeline.source).create_thumbnail })
    end

    AddSortFieldsTransform = lambda do |data, pipeline|
      data.merge({ 'sort_title_ssi' => pipeline.source.sidecar.data['configured_fields']['full_title_tesim'] })
      # TO DO: add date created sort option
    end

    AddCompoundIdsTransform = lambda do |data, pipeline|
      return data unless pipeline.source.compound_ids.present?
      data.merge({ 'compound_ids_ssim' => pipeline.source.compound_ids })
    end

    # Index facet fields as ssim to preserve capitalization (tesim and ftesim fields are lowercase)
    TransformFacetFieldsTransform = lambda do |data, _pipeline|
      facet_fields = CatalogController.blacklight_config.facet_fields.keys.select { |key| data.keys.include?(key) }
      return data if facet_fields.empty?

      transformed = facet_fields.each_with_object({}) do |field, hash|
        next if data[field].blank?
        # Convert key: e.g. spotlight_upload_dc_Subjects_ftesim => spotlight_upload_dc_Subjects_facet_ssim
        new_key = field.split("_")[0..-2].join("_") + "_facet_ssim"
        # Convert string values to an array
        # "Subject 1; Subject 2; Subject 3" => ["Subject 1","Subject 2", "Subject 3"]
        hash[new_key] = Array.wrap(data[field]).flatten.first.split("\;").select(&:present?).map(&:strip)
      end
      data.merge(transformed)
    end

  end
end
