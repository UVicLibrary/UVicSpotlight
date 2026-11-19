# frozen_string_literal: true

# EXTEND blacklight v.8.3.0 to handle some custom field types:
#   - automatically turn strings starting with http(s) into links
#   - render the human-readable version of EDTF dates
#   - render Parent field as link to the parent object (with title)
class CustomFieldPresenter < Blacklight::FieldPresenter

  delegate :blacklight_config, :current_exhibit, :solr_document_path, to: :view_context

  def render
    Array.wrap(values).flatten.map do |val|
      if val.match?('http')
        val.scan((/(https?:\/\/.+?)($|\s|\;)/)).map(&:first).each do |link|
          val = val.sub(link, render_link_to(link))
        end
        # Must be sanitized downstream in a component.html.erb or a view partial
        # Calling view_context.sanitize here doesn't seem to work
        val
      elsif parent_field?(field_config)
        # Must be sanitized downstream in a component.html.erb or a view partial
        # Calling view_context.sanitize here doesn't seem to work
        render_parent_link_to(val)
      elsif date_field?(field_config)
        render_date(val)
      else
        val
      end
    end.join('; ')
  end

  def component
    CustomMetadataFieldComponent
  end

  private

  # Open links in new tabs
  def render_link_to(field_value)
    component.new(field: field_config).link_to(field_value, target: "_blank") do
      field_value
    end
  end

  def parent_field?(field_config)
    field_config.key == "parent_ids_ssim"
  end

  def render_parent_link_to(field_value)
    # config = try(:blacklight_config) || view_context.blacklight_config
    parent = Blacklight::SearchService.new(config: blacklight_config).fetch(field_value)
    title = parent.fetch(blacklight_config.index.title_field).first
    component.new(field: field_config).link_to("/spotlight/#{current_exhibit.slug}" + solr_document_path(field_value)) do
      title
    end
  end

  def date_field?(field_config)
    field_config.key == "spotlight_upload_dc_Date_tesi"
  end

  def render_date(value)
    begin
      EdtfDateService.new(value).humanized
    rescue EdtfDateService::InvalidEdtfDateError
      value
    end
  end

end