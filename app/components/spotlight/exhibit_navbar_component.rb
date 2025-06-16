# frozen_string_literal: true
# TO DO: Delete after upgrading to 5.1.0 as this file is identical to Spotlight
module Spotlight
  # Allows component addition to exhibit navbar
  class ExhibitNavbarComponent < ViewComponent::Base
    renders_one :prepend_to_search_bar

    def search_component
      helpers.blacklight_config&.view_config(helpers.document_index_view_type)&.search_bar_component || Blacklight::SearchBarComponent
    end
  end
end