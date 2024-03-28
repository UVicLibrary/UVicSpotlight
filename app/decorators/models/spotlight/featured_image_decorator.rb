Spotlight::FeaturedImage.class_eval do

  def iiif_url
    return unless iiif_service_base.present?
    extension = (self.image.try(:identifier).try(:include?, '.png') ? 'png' : 'jpg' )
    [iiif_service_base, iiif_region || 'full', image_size.join(','), '0', "default.#{extension}"].join('/')
  end

end