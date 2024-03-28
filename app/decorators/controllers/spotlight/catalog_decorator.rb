Spotlight::CatalogController.class_eval do

  # before_action only: [:show, :edit, :update] do
  #   @resource = Spotlight::Resource.find(params[:id].split("-").last.to_i)
  # end

  before_action only: [:video, :manifest] do
    #solr_document_params
    setup_next_and_previous_documents
  end

  before_action only: :edit do
    blacklight_config.view.edit.partials = blacklight_config.view_config(:show).partials.dup - [:metadata]
    blacklight_config.view.edit.partials.insert(2, :edit)
  end

  def show
    super

    authenticate_user! && authorize!(:curate, current_exhibit) if @document.private? current_exhibit

    add_document_breadcrumbs(@document)
    @resource = @document.resource

    if @document.uploaded_resource?
      if @resource.compound_object?
        query = "id:(#{@resource.compound_ids.join(" OR ")})"
        _response, @child_docs = search_service.search_results do |builder|
          builder.with({
                           q: query,
                           rows: 500,
                           qt: 'standard'
                       })
        end
      end
    end
  end

  def update
    @response, @document = search_service.fetch params[:id]
    @resource = @document.resource

    if params[:solr_document][:uploaded_resource]
      new_file_name = params[:solr_document][:uploaded_resource][:url].original_filename
      @resource.file_name = new_file_name if new_file_name.present?
    end
    @resource.save
    @resource.reindex

    @document.update(current_exhibit, solr_document_params)
    @document.save
    try_solr_commit!

    redirect_to polymorphic_path([current_exhibit, @document])
  end


  def edit
    @response, @document = search_service.fetch params[:id]
    @resource = @document.resource
    @docs = []
  end

  # Searches for individual items to be combined into a manifest/compound object.
  # Returns a list of items with titles, option to add.
  def search
    # noop
  end

  def manifest_presenter_class
    _, @document = search_service.fetch params[:id]
    @resource = @document.resource

    if @document.uploaded_resource?
      # @resource = @document.uploaded_resource
      case @resource.file_type
      when "image"
        ImageIiifManifestPresenter
      when "compound object"
        CompoundObjectIiifManifestPresenter
      else
        # This shouldn't really matter because we don't use the
        # manifests to display/view other file types anyway.
        ImageIiifManifestPresenter
      end
    else
      ImportIiifManifestPresenter
    end
  end

  # Render a manifest as a raw json file
  # Order of operations: Spotlight's pre-generated manifest -> modified manifest
  # -> manifest_fullscreen -> _mirador partial.
  # Catalog#show calls openseadragon_default view, which has an iframe to mirador.
  # See http://projectmirador.org/docs/docs/getting-started.html#iframe
  def manifest
    manifest = manifest_presenter_class.new(@document, self).iiif_manifest_json
    render json: manifest
  end

  # Uses manifest (generated by catalog#manfest) & renders fullscreen Mirador viewer for image or compound object
  def mirador
    _, @document = search_service.fetch params[:id]
    respond_to do |format|
      format.html { render "catalog/viewers/mirador", layout: false } # Don't render masthead or other stuff
    end
  end

end