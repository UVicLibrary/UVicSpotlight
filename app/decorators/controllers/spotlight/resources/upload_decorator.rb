Spotlight::Resources::UploadController.class_eval do

  attr_accessor :featured_image

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def create
    @resource.attributes = resource_params
    # We need to set a featured_image for each resource, even if the
    # file itself is not an image. The resource won't save and index
    # without it.
    @resource.upload = Spotlight::FeaturedImage.create(image: params[:resources_upload][:url])

    # Is compound object
    if params[:resources_upload][:compound_ids].presence
      @resource.compound_ids = JSON.parse(params[:resources_upload][:compound_ids].first)
    else
      @resource.file_name = set_file_name
    end

    if @resource.save_and_index
        @resource.reindex  # Sometimes the resource doesn't show up in Solr until we reindex again
        flash[:notice] = t('spotlight.resources.upload.success')
        return redirect_to new_exhibit_resource_path(@resource.exhibit, tab: :upload) if params['add-and-continue']
    else
      flash[:error] = t('spotlight.resources.upload.error')
    end

    redirect_to admin_exhibit_catalog_path(@resource.exhibit, sort: :timestamp)
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def set_file_name
    @resource.upload.image.file.filename
  end

end