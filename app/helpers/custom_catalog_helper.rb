module CustomCatalogHelper

  # Custom methods for the catalog#show page.

  def render_download_item_link(document)
    # Don't render a download link for compound objects
    return '' if resource_for(document).compound_object?
    sanitize("<a href='#{download_item_path(document)}'>Download Item</a>")
  end

  def download_item_path(document)
    resource = resource_for(document)
    case resource.file_type
    when "image"
      "/images/#{resource.upload_id}/full/full/0/default.jpg"
    else
      file_url(resource)
    end
    # TO DO: imported objects
    # download_url = "#{document._source["jpeg_url_ssm"].first}"
  end

  # Overrides Blacklight::ShowPresenter method
  def field_value(presenter, field)
    value = presenter.field_value(field)
    if multiple?(value)
      sanitize(value.split(/ ?; ?/).map do |val|
        val.start_with?('http') ? sanitize(render_link_to(val)) : Nokogiri::XML.fragment(sanitize(scrub_value(val)))
      end.join('; '))
    else
      value.start_with?('http') ? sanitize(render_link_to(value)) : Nokogiri::XML.fragment(sanitize(scrub_value(value)))
    end
  end

  def media_display(document, locals = {})
    render(media_display_partial(document), locals.merge(document: document))
  end

  def child_resources(doc_ids)
    doc_ids.map do |id|
      Spotlight::Resource.find(id.split("-").last)
    end
  end

  def resource_id_for(document)
    document.id.split("-").last
  end

  def file_url(resource)
    parser = URI::Parser.new
    "/uploads/spotlight/featured_image/image/#{resource.upload_id}/#{parser.escape(resource.file_name)}"
  end

  def video_thumb_path(resource)
    filename = "video_thumb_#{resource.file_name.to_s.split(".").first}.jpeg"
    # The path to the file on the local server
    path = "#{File.dirname(resource.upload.image.path)}/#{filename}"
    # The Spotlight url that the file is available at
    url = "#{File.dirname(resource.upload.image_url)}/#{filename}"
    url if File.exist?(path)
  end

  private

  def media_display_partial(document)
    resource = resource_for(document)
    if resource.file_type == "compound object"
      "catalog/viewers/" + resource.made_of
    else
      "catalog/viewers/" + resource.file_type
    end
  end

  def resource_for(document)
    Spotlight::Resource.find(resource_id_for(document))
  end

  def render_link_to(field_value)
    link_to(field_value) do
      field_value
    end
  end

  def multiple?(value)
    value.include? ";"
  end

  def scrub_value(value)
    sanitize(value.gsub("&lt;", "<").gsub("&gt;", ">"))
  end

end