module CustomCatalogHelper

  # Custom methods for the catalog#show page.

  # Overrides Blacklight::ShowPresenter method
  # @param [Blacklight::ShowPresenter]
  # @param [Blacklight::Configuration::IndexField]
  def field_value(presenter, field)
    # Coerce string values into an array
    Array.wrap(presenter.field_value(field)).flatten.map do |val|
      if val.match?('http')
        val.scan((/(https?:\/\/.+?)($|\s|\;)/)).map(&:first).each do |link|
          val.gsub!(link, render_link_to(link))
        end
        val
      elsif parent_field?(field)
        render_parent_link_to(val)
      elsif date_field?(field)
        render_date(val)
      else
        val
      end
    end.join('; ')
  end

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

  def render_link_to(field_value)
    link_to(field_value, target: "_blank") do
      field_value
    end
  end

  def parent_field?(field)
    field.key == "parent_ids_ssim"
  end

  def render_parent_link_to(field_value)
    parent = Blacklight::SearchService.new(config: blacklight_config).fetch(field_value)
    title = parent.fetch(blacklight_config.index.title_field).first
    link_to("/spotlight/#{current_exhibit.slug}" + solr_document_path(field_value), target: "_blank") do
      title
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