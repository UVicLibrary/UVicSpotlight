class ImportIiifManifestPresenter < ImageIiifManifestPresenter

  def iiif_manifest_json
    manifest = JSON.parse(iiif_manifest)
    add_attribution(manifest)
    add_logo(manifest)
    add_metadata(manifest)
    update_manifest_id(manifest)
    JSON.pretty_generate(manifest)
  end

  private

  def iiif_manifest
    `curl #{iiif_url}`
  end

  # Note: @resource is the SolrDocument and not the Spotlight::Resource
  def iiif_url
    @resource['iiif_manifest_url_ssi']
  end

  # Use spotlight manifest @id instead of Vault one
  def update_manifest_id(manifest)
    manifest['@id'] = manifest_url
  end

end