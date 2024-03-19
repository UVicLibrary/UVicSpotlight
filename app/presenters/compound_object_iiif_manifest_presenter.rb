class CompoundObjectIiifManifestPresenter < ImageIiifManifestPresenter

  # Displays compound objects that are made of images, e.g. a book that is
  # made up of many pages. Each page becomes a "canvas" in the IIIF manifest.
  # IIIF docs on components of a valid manifest: https://iiif.io/api/presentation/2.1/

  # @return [<JSON>] - the JSON used by the mirador viewer
  def iiif_manifest_json
    manifest = JSON.parse(super)
    child_docs = child_docs_query(@resource.uploaded_resource.compound_ids)
    sequence = manifest['sequences'][0]

    # The compound object itself shouldn't be listed as a canvas
    # so we need to empty the sequence of all canvases
    sequence['canvases'] = []

    canvases = child_docs.map do |document|
      canvas = build_canvas(document)
      canvas['images'] = Array.wrap(build_image(document))
      canvas['images'][0]['resource'] = build_resource(document)
      canvas['images'][0]['resource']['service'] = build_service(document)
      canvas
    end

    sequence['canvases'] = canvases
    JSON.pretty_generate(manifest)
  end

  # Search Solr for a compound object's child documents.
  # @param [Array <String>] - The document ids to search for, e.g. ["2-6","2-7"]
  # #return [Array <SolrDocument>] - The docs corresponding to those ids
  def child_docs_query(ids_array)
    solr = RSolr.connect url: Blacklight::Configuration.new.connection_config[:url]
    query = "id:(#{ids_array.join(" OR ")})"

    response = solr.get 'select', params: { q: query, rows: 1000, qt: 'standard' }
    response['response']['docs']
  end

  def base_url
    controller.request.base_url
  end

  def build_canvas(document)
    hash = {}
    hash['@id'] = canvas_id(document)
    hash['@type'] = "sc:Canvas"
    hash['label'] = document["full_title_tesim"]
    hash['width'] = document["spotlight_full_image_width_ssm"].first.to_i
    hash['height'] = document["spotlight_full_image_height_ssm"].first.to_i
    hash
  end

  def canvas_id(document)
    "#{base_url}/catalog/#{document['id']}/manifest/#{document['id']}"
  end

  def build_image(document)
    hash = {}
    hash['@type'] = "oa:Annotation"
    hash['motivation'] = "sc:painting"
    hash['on'] = canvas_id(document)
    hash
  end

  def build_resource(document)
    hash = {}
    hash['@id'] = canvas_id(document)
    hash['@type'] = "dctypes:Image"
    hash['width'] = document["spotlight_full_image_width_ssm"].first.to_i
    hash['height'] = document["spotlight_full_image_height_ssm"].first.to_i
    hash['format'] = "image/jpeg"
    hash
  end

  def build_service(document)
    hash = {}
    hash['@context'] = "http://iiif.io/api/image/2/context.json"
    # Note this needs to be the featured image ID
    hash['@id'] = "#{base_url}/images/#{image_id(document)}"
    hash['profile'] = "http://iiif.io/api/image/2/level2.json"
    hash
  end

  def image_id(document)
    # Get the resource id from the 2nd half of the document id
    resource_id = document['id'].split("-").last.to_i
    Spotlight::Resource.find(resource_id).upload_id
  end

end