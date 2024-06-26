# frozen_string_literal: true
Spotlight::ResourcesController.class_eval do
  include Spotlight::Catalog

  def create
    if @resource.url.present?
      manifest = @resource.iiif_manifests.first # See /models/spotlight/resources/vault_iiif_manifest.rb
      manifest.with_exhibit(@resource.exhibit)
      manifest.with_resource(@resource)
      @resource.file_name = "default.jpg" # needed for calculating resource.file_type
      @resource.data = manifest.manifest_metadata.transform_values { |v| v.first unless v.nil? } # We want to index the SolrDocument with a multiple value ({ k => ['v'] }
      # but Resource.data should index the string value, data: { k => 'v' }
    end
    if @resource.save_and_index
      if @resource.imported?
        flash[:notice] = "Your item is being imported from Vault. Please check back later or refresh the page."
      end
      redirect_to spotlight.admin_exhibit_catalog_path(@resource.exhibit, sort: :timestamp)
    else
      flash[:error] = @resource.errors.full_messages.to_sentence if @resource.errors.present?
      render action: 'new'
    end
  end

  def destroy
    @resource = Spotlight::Resource.find(params[:id])
    @exhibit = @resource.exhibit
    @resource.destroy
    flash[:notice] = "Item was successfully deleted"
    redirect_to admin_exhibit_catalog_path(@exhibit)
  end

  def new_compound_object
    @resource = Spotlight::Resources::Upload.new
    add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), exhibit_root_path(@exhibit)
    add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
    add_breadcrumb t(:'spotlight.curation.sidebar.items'), admin_exhibit_catalog_path(@exhibit)
    add_breadcrumb "Add compound object", request.original_url
  end

  def index
    # Search for documents on new_compound_object page
    if params[:cdq]
      search_child_docs
      respond_to do |format|
        format.js {
          render partial: 'results'
        }
      end
    end
  end

  def google_map
    # Direct connection
    solr = RSolr.connect url: Blacklight::Configuration.new.connection_config[:url]

    # Spotlight needs the exhibit ID to find custom metadata fields (location is no longer a default metadata field)
    exhibit_id = current_exhibit.slug

    query = "*:*" #self.search.nil? ? "*:*" : self.search.gsub(',',' OR ')
    res = solr.get 'select', :params => {
        :q=>query,
        :start=>0,
        :rows=>1000,
        :fl=> ["id", "spotlight_exhibit_slugs_ssim", "full_title_tesim",
               "spotlight_upload_description_tesim", "thumbnail_url_ssm",
               "exhibit_#{exhibit_id}_location_ssim"],
        :fq=> "exhibit_#{exhibit_id}_location_ssim:[* TO *]",
        :wt=> "ruby"
    }

    @items = []
    # only return items that have a valid lat/long in its location field
    res['response']['docs'].each do |r|
      if r['exhibit_test-exhibit_location_ssim'].first.match(/(-?\d{1,3}\.\d+)/) != nil
        @items.push(r)
      end
    end
    @items.sort!{|a,b| a['full_title_tesim'][0].downcase <=> b['full_title_tesim'][0].downcase}
    # render json: @items.to_json
  end

  def search_child_docs
    _response, @results = search_service.search_results do |builder|
      builder.with({
          q: params[:cdq],
          rows: 20,
          fl: ["id", "full_title_tesim", "spotlight_upload_description_tesim", "thumbnail_url_ssm"],
          # TO DO: Limit this to images, video, and audio only
          fq:["spotlight_exhibit_slug_#{@exhibit.slug}_bsi:true"]
       })
    end
  end

  def resource_params
    params.require(:resource).tap { |x| x['type'] ||= resource_class.name }
        .permit(:url, :type, :cdq, *resource_class.stored_attributes[:data], data: params[:resource][:data].try(:keys))
  end


end