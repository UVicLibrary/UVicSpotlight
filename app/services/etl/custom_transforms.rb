module Etl
  module CustomTransforms
    # Add custom indexing fields to this file.
    #   data - the index document that is eventually pushed to Solr
    #   pipeline.source - the resource object, call pipeline.source.sidecar['data'] to get
    #                     metadata entered into the edit form

    AddFileTypeTransform = lambda do |data, pipeline|
      data.merge({ 'resource_file_type_ssi' => pipeline.source.file_type })
    end

    AddSketchfabUidTransform = lambda do |data, pipeline|
      uid = pipeline.source.uid
      data.merge({ 'spotlight_upload_Sketchfab-uid_tesim' => uid })
    end

    Add3DModelIdTransform = lambda do |data, pipeline|
      data.merge({ 'spotlight_upload_3d_model_id_tesim' => pipeline.source.model_id },
                 { 'thumbnail_url_ssm' => ThumbnailService.new(pipeline.source).create_thumbnail })
    end

    AddSortFieldsTransform = lambda do |data, pipeline|
      data.merge({ 'sort_title_ssi' => pipeline.source.sidecar.data['configured_fields']['full_title_tesim'] })
      # TO DO: add date created sort option
    end

  end
end
