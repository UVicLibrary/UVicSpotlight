Spotlight::Resource.class_eval do

  FILE_TYPES_LIST = ["image", "video", "compound object", "pdf", "model", "audio"]

  def file_type
    if self.compound_ids? or self.imported_compound_object?
      "compound object"
    elsif self.file_name?
      mime_type = Rack::Mime.mime_type(File.extname(self.file_name))
      if mime_type.include?('ogg')
        "video/audio"
      elsif mime_type.include?('video')
        "video"
      elsif mime_type.include?('audio')
        "audio"
      elsif mime_type.include?('image')
        "image"
      elsif ['.stl', '.obj', '.3ds', '.zip'].any? { |ext| self.file_name.include?(ext) }
        "model"
      elsif mime_type.include?('pdf')
        "pdf"
      else
        "unknown"
      end
    end
  end

  # Returns file_type of a compound object's parts (image, video, audio)
  def made_of
    return nil if self.file_type != "compound object"
    if self.imported_compound_object?
      "image"
    else
      ::SolrDocument.find(self.compound_ids[0]).uploaded_resource.file_type if ::SolrDocument.find(self.compound_ids[0]).uploaded_resource?
    end
  end

  def compound_object?
    self.file_type == "compound object"
  end

  def imported?
    self.class == Spotlight::Resources::IiifHarvester
  end

  def imported_compound_object?
    if self.imported?
      document = ::SolrDocument.find("#{exhibit.id}-#{self.id}")
      document['content_metadata_image_iiif_info_ssm'].length > 1
    else
      false
    end
  end

  def destroy
    delete_document
    super
  end

  private

  def delete_document
    solr = RSolr.connect url: Blacklight::Configuration.new.connection_config[:url]
    doc_id = "#{self.exhibit_id}-#{self.id}"
    solr.delete_by_id doc_id
    solr.commit
  end

end