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

    AddModelIdTransform = lambda do |data, pipeline|
      return data unless data['spotlight_upload_3d_model_url_tesim'].present?
      model_id = data['spotlight_upload_3d_model_url_tesim'].split("/").last.split("?").first
      data.merge({ 'spotlight_upload_3d_model_id_tesim' => model_id })
    end

    AddSortFieldsTransform = lambda do |data, pipeline|
      data.merge({ 'sort_title_ssi' => pipeline.source.sidecar.data['configured_fields']['full_title_tesim'] })
      # TO DO: add date created sort option
    end

    AddCompoundIdsTransform = lambda do |data, pipeline|
      return data unless pipeline.source.compound_ids.present?
      data.merge({ 'compound_ids_ssim' => pipeline.source.compound_ids })
    end

    # Index facet fields as ssim to preserve capitalization (tesim and ftesim fields are automatically
    # coerced into lowercase as part of tokenization)
    TransformFacetFieldsTransform = lambda do |data, _pipeline|
      # For each potential facet field, find the matching upload field
      facet_fields = CatalogController.blacklight_config.facet_fields.map(&:first)
      upload_fields = Spotlight::Engine.config.upload_fields.map(&:field_name)
      matching_fields = upload_fields.select do |upload_field|
        root = upload_field.split("_")[0..-2].join("_") # The field name sans Solr suffix
        next unless facet_fields.include?(root + "_facet_ssim")
        # If there are both non-faceted and faceted versions of the same field,
        # take only the faceted version
        if upload_fields.include?(root + "_ftesim") || upload_fields.include?(root + "_ftesi")
          upload_field.ends_with?("ftesim") || upload_field.ends_with?("ftesi")
        else
          true
        end
      end + ["spotlight_upload_dc_Date_tesi"]

      transformed = matching_fields.each_with_object({}) do |field, hash|
        next if data[field].blank?
        # Convert key: e.g. spotlight_upload_dc_Subjects_ftesim => spotlight_upload_dc_Subjects_facet_ssim
        new_key = field.split("_")[0..-2].join("_") + "_facet_ssim"
        # Convert string values to an array
        # "Subject 1; Subject 2; Subject 3" => ["Subject 1","Subject 2", "Subject 3"]
        hash[new_key] = Array.wrap(data[field]).flatten.first.split("\;").select(&:present?).map(&:strip)
      end
      data.merge(transformed)
    end

    AddDateFieldsTransform = lambda do |data, _pipeline|
      return data unless data["spotlight_upload_dc_Date_tesi"].present?
      year_range_values = []
      sort_date_values = []

      data["spotlight_upload_dc_Date_tesi"].split("\;").map(&:strip).each do |date|
        begin # Try to parse EDTF-compatible dates
          service = EdtfDateService.new(date)
          year_range_values << service.year_range
          sort_date_values << service.first_solr_date
        rescue EdtfDateService::InvalidEdtfDateError
          # Intentionally blank
        end
      end
      return data unless (year_range_values && sort_date_values)
      data.merge({
        "spotlight_year_range_isim" => year_range_values.flatten.uniq,
        "spotlight_sort_date_tesi" => sort_date_values.sort.first
      })
    end

  end
end
