class GoogleMapBlock < SirTrevorRails::Block


  def get_exhibit_slug
    parent.exhibit.slug # e.g. mcm
  end

  #get items from solr to display on the map block
  #search value is from block
  def getsolr
  	items = Array.new
    solr = RSolr.connect url: Blacklight::Configuration.new.connection_config[:url]

    #wade, castri, norbury, abkhazi
    slug_filter = "spotlight_exhibit_slugs_ssim:#{get_exhibit_slug}"

    query = "*:*"#self.search.nil? ? "*:*" : self.search.gsub(',',' OR ')
    res = solr.get 'select', :params => {
      :q=>query,
      :start=>0,
      :rows=>500,
      :fl=> ["id", "spotlight_exhibit_slugs_ssim", "full_title_tesim", "spotlight_upload_dc_description_tesim", "thumbnail_url_ssm", "spotlight_upload_dc_Coverage-Spatial_Location_tesim"],
      :fq=> ["spotlight_upload_dc_Coverage-Spatial_Location_tesim:[* TO *]", slug_filter],
      :wt=> "ruby"
    }

    # only return items that have a valid lat/long in its location field
    res['response']['docs'].each do |d|
      if d["spotlight_upload_dc_Coverage-Spatial_Location_tesim"][0].match(/(-?\d{1,3}\.\d+)/) != nil
        items.push(d)
      end
    end

  	#sort items by title
  	items.sort!{|a,b| a['full_title_tesim'][0].downcase <=> b['full_title_tesim'][0].downcase}

    end



end
