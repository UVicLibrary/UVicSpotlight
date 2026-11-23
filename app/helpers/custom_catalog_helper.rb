module CustomCatalogHelper

  # Custom methods for the catalog#show page.

  def render_download_item_link(document)
    # Don't render a download link for compound objects
    return '' if document.compound_object?
    link_to("Download item", download_item_path(document), target: '_blank')
  end

  def download_item_path(document)
    case document.file_type
    when "image"
      # "/images/#{resource.upload_id}/full/full/0/default.jpg"
      document.thumbnail_url.sub('!400,400','full')
    else
      document.upload_url
    end
  end

  def media_display(document, locals = {})
    render(media_display_partial(document), locals.merge(document: document))
  end

  private

  def media_display_partial(document)
    if document.file_type == "compound object"
      "catalog/viewers/" + document.child_file_type
    else
      "catalog/viewers/" + document.file_type
    end
  end

end