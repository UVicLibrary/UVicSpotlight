class ImageIiifManifestPresenter < Spotlight::IiifManifestPresenter

  # Adds custom properties to the default Spotlight::IiifManifestPresenter
  #   - Display all configured Spotlight metadata fields
  #   - Add logo
  #   - Add attribution that corresponds to the Rights field in the metadata

  # IIIF docs on components of a valid manifest: https://iiif.io/api/presentation/2.1/
  # @return [<JSON>] - the JSON used by the mirador viewer
  def iiif_manifest_json
    manifest = JSON.parse(iiif_manifest.to_h.to_json)
    add_attribution(manifest)
    add_logo(manifest)
    add_metadata(manifest)
    JSON.pretty_generate(manifest)
  end

  private

    # @return [<Hash>] - the resulting manifest
    # Note: @resource is the SolrDocument and not the Spotlight::Resource
    def add_attribution(manifest)
      attribution = @resource['spotlight_upload_Rights_tesim'][0] if @resource['spotlight_upload_Rights_tesim']
      manifest['attribution'] = attribution if attribution.presence
      manifest
    end

    # @return [<Hash>] - the resulting manifest
    def add_logo(manifest)
      path = "#{controller.request.base_url}#{ActionController::Base.helpers.asset_path("libr_logo_comb.jpg")}"
      manifest['logo'] = path
      manifest
    end

    # @return [<Hash>] - the resulting manifest
    # Note: @resource is the SolrDocument and not the Spotlight::Resource
    def add_metadata(manifest)
      metadata = fields.map do |field|
        next if (excluded_field_labels.include?(field.label) || @resource.keys.exclude?(field.field_name))
        values = Array.wrap(@resource[field.field_name]).flatten.join('/n')
        label = field.label
        { 'label' => label, 'value' => values }
      end.select(&:presence)
      # Unescape HTML entities that are are escaped by the IIIF manifest gem
      manifest['label'] = Nokogiri::XML.fragment(manifest['label']).text
      manifest['metadata'] = metadata
    end

    # Mirador 3 already displays the title prominently, so no need to
    # display it twice. Rights is also duplicated in the attribution element.
    def excluded_field_labels
      ["Title","Rights"]
    end

    def fields
      Spotlight::Resources::Upload.fields(controller.current_exhibit)
    end

end