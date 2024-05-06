module Etl
  module CustomTransforms

    AddFileTypeTransform = lambda do |data, pipeline|
      data.merge({ 'resource_file_type_ssi' => pipeline.source.file_type })
    end

    AddSketchfabUidTransform = lambda do |data, pipeline|
      uid = pipeline.source.uid || pipeline.source.data['spotlight_upload_Sketchfab-uid_tesim']
      data.merge({ 'spotlight_upload_Sketchfab-uid_tesim' => uid })
    end

  end
end
