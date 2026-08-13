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
  # @param [Blacklight::ShowPresenter]
  # @param [Blacklight::Configuration::IndexField]
  def field_value(presenter, field)
    # Coerce string values into an array
    Array.wrap(presenter.field_value(field)).flatten.map do |val|
      if val.match?('https')
        link = val.match(/(https:\/\/.+?)($|\s)/)[1]
        val.gsub(link, render_link_to(link))
      elsif date_field?(field)
        render_date(val)
      else
        val
      end
    end.join('; ')
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

  def date_field?(field)
    field.key == "spotlight_upload_dc_Date_tesi"
  end

  def render_date(value)
    begin
      EdtfDateService.new(value).humanized
    rescue EdtfDateService::InvalidEdtfDateError
      value
    end
  end

end