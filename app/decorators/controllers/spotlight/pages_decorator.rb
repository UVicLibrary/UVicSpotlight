Spotlight::PagesController.class_eval do

  # The autocomplete endpoint for the FeaturedPagesBlock
  def index
    # set up a model the inline "add a new page" form
    @page = CanCan::ControllerResource.new(self).send(:build_resource)

    respond_to do |format|
      format.html
      # Also show pages the current user can edit (instead of only published pages)
      format.json { render json: @pages.for_default_locale.select { |page| can?(:edit,page) }.to_json(methods: [:thumbnail_image_url]) }
    end
  end

end