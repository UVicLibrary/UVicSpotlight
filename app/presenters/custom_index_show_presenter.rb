class CustomIndexShowPresenter < Blacklight::IndexPresenter

  # OVERRIDE blacklight 8.3.0
  # Replace field_config.presenter with our custom class, CustomFieldPresenter
  def field_presenter(field_config, options = {})
    CustomFieldPresenter.new(view_context, document, field_config, field_presenter_options.merge(options))
  end

end