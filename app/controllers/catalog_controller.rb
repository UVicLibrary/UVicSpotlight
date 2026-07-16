##
# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog
  include Blacklight::Configurable
  include Blacklight::SearchContext
  include Spotlight::Catalog

  # Error: InvalidAuthenticityToken
  skip_before_action :verify_authenticity_token, only: :track

  # This should apply to all CatalogController sub-classes too. They all share a counter though.
  #
  # We let bots through if they have NO query params, we want to let collection/focus splash
  # pages be indexed -- this will actually let bot paginate through entire results with
  # no query/facets, which we seem to be able to tolerate.
  bot_challenge if: -> { action_name != "track" && has_search_parameters? }, except: ["facet", "range_limit"]

  # facet and range_limit both get challenged immediately, unless they are JS fetch,
  # in which case they are let in freely.
  bot_challenge only: ["facet", "range_limit"], unless: -> {
    request.headers["sec-fetch-dest"] == "empty"
  }

  configure_blacklight do |config|
    config.bootstrap_version = 4
    config.show.oembed_field = :oembed_url_ssm
    config.show.partials = [:item_viewer, :metadata]
    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    # Have CustomDocumentComponent be the default document_component
    config.show.document_component = CustomDocumentComponent

    config.view.gallery(document_component: Blacklight::Gallery::DocumentComponent, partials: [:index_header, :index])
    config.view.masonry(document_component: Blacklight::Gallery::DocumentComponent, partials: [:index])
    config.view.slideshow(document_component: Blacklight::Gallery::SlideshowComponent, partials: [:index])
    config.view.embed!.partials = [:item_viewer]

    config.index.title_field = 'full_title_tesim'

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10
      # fl: '*',
      # q: '*:*'
    }

    config.document_solr_path = 'get'
    config.document_unique_id_param = 'ids'


    config.add_search_field 'all_fields', label: I18n.t('spotlight.search.fields.search.all_fields')
    config.add_sort_field 'title', sort: 'sort_title_ssi asc', label: 'Title'

    #config.add_sort_field 'relevance', sort: 'score desc', label: I18n.t('spotlight.search.fields.sort.relevance')
    blacklight_config.add_sort_field :relevance, default: true,
                                     sort: "#{blacklight_config.index.relevance_field} score desc"

    # Configure facet fields
    config.add_facet_field 'spotlight_upload_dc_Subjects_ftesim', label: "Subject(s)", limit: true
    config.add_facet_field 'spotlight_upload_dc_Date-Created_Searchable_ftesi', label: 'Date', limit: true
    config.add_facet_field 'spotlight_upload_dc_Type_Genre_ftesim', label: 'Genre', limit: true
    config.add_facet_field 'spotlight_upload_Language_ftesim', label: 'Language', limit: true
    config.add_facet_field "spotlight_upload_dc_Coverage-Spatial_Location_ftesim", label: 'Location(s)', limit: true
    config.add_facet_field "spotlight_upload_dc_Subject_People_ftesim", label: 'People', limit: true
    config.add_facet_field "spotlight_upload_dc_Relation_IsPartOf_Collection_ftesim", label: 'Collection', limit: true
    config.add_facet_field "spotlight_upload_Format_tesim", label: 'Format', limit: true
    config.add_facet_field "spotlight_upload_Coverage-Temporal_tesim", label: 'Coverage - Temporal', limit: true

    config.add_field_configuration_to_solr_request!
    config.add_facet_fields_to_solr_request!

    # Set which views by default only have the title displayed, e.g.,
    # config.view.gallery.title_only_by_default = true

    # Some components can be configured
    # config.index.document_component = MyApp::SearchResultComponent
    # config.index.constraints_component = MyApp::ConstraintsComponent
    # config.index.search_bar_component = MyApp::SearchBarComponent
    # config.index.search_header_component = MyApp::SearchHeaderComponent
    config.index.document_actions.delete(:bookmark)

    # config.add_results_document_tool(:bookmark, partial: 'catalog/bookmark_control', if: :render_bookmarks_control?)
    # config.add_show_tools_partial(:bookmark, component: Blacklight::Document::BookmarkComponent, if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    # config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

  end
end
