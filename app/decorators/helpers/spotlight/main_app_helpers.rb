Spotlight::MainAppHelpers.module_eval do

  def exhibit_stylesheet_link_tag(tag)
    if current_exhibit_theme && current_exhibit&.theme != 'default'
      stylesheet_link_tag "#{tag}_#{current_exhibit_theme}"
    else
      # Suppress warning about exhibit theme.
      # Rails.logger.warn "Exhibit theme '#{current_exhibit_theme}' not in white-list of available themes: #{current_exhibit&.themes}"
      stylesheet_link_tag(tag)
    end
  end

end