class ImportIiifManifestPresenter < UploadIiifManifestPresenter

  def iiif_manifest_json
    #   #source_m = Spotlight::IiifManifestPresenter.new(@document, self).iiif_manifest_json
    #   conn = Faraday.new(@document['iiif_manifest_url_ssi'], { ssl: {verify:false}})
    #   source_m = conn.get.body
    #   manifest = IIIF::Service.parse(JSON.parse(source_m))
    #   #byebug
    #   # Add attribution and logo
    #   add_resource_properties(manifest)
    #   manifest = manifest.to_json(pretty: true)

    # If the compound object has a title, use that. If not, use the first resource's title.
    # @first_resource = ::SolrDocument.find(child_docs.first).uploaded_resource
    # if @resource.data["full_title_tesim"].blank?
    #   resource_title = first_resource_title
    # else
    #   resource_title = @resource.data["full_title_tesim"]
    # end
    #
  end

  private

  # Note: @resource is the SolrDocument and not the Spotlight::Resource
  def fields
    @resource.sidecar(current_exhibit).data['configured_fields'].keys
  end

  # Note: @resource is the SolrDocument and not the Spotlight::Resource
  def iiif_url
    @resource['iiif_manifest_url_ssi']
  end

end