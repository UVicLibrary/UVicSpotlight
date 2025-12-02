class ThumbnailService
  include VideoThumbnailer

  require 'fileutils'
  require 'rest_client'

  def initialize(resource)
    @resource = resource
  end

  # The file path to the thumbnail
  def full_thumbnail_dir_path
    Rails.root.join("public", thumbnail_dir_path(@resource))
  end

  def thumbnail_dir_path(resource)
    "uploads/spotlight/featured_image/image/#{resource.upload_id}"
  end

  # Creates thumbnails based on file type and returns the
  # path to the generated thumbnail
  def create_thumbnail
    case @resource.file_type
    when "image"
      riiif.image_path(@resource.upload_id, size: '!400,400')
    when "compound object"
      if @resource.made_of == "image"
        riiif.image_path(first_resource(@resource).upload_id, size: '!400,400')
      elsif @resource.made_of == "video"
        first_resource = first_resource(@resource)
        # Video thumbnail generation is handled by VideoThumbnailer gem
        # See app/uploaders/spotlight/featured_image_uploader and
        # https://github.com/teenacmathew/Video-Thumbnailer
        "/#{thumbnail_dir_path(first_resource)}/video_thumb_#{first_resource.file_name.split('.').first}.jpeg"
      elsif @resource.made_of == "audio"
        "/uploads/spotlight/audio.png"
      end
    when "pdf"
      pdf_name = File.basename(@resource.file_name, '.pdf')
      # Run vips from the command line
      `vips thumbnail #{full_thumbnail_dir_path}/#{@resource.file_name} #{full_thumbnail_dir_path}/#{pdf_name}-thumb.jpg 500x`
      # Return the thumbnail path for indexing
      "/#{thumbnail_dir_path(@resource)}/#{pdf_name}-thumb.jpg"
    when "model"
      if @resource.model_id
        "#{KOMPAKKT_DOMAIN_NAME}/server/previews/entity/#{@resource.model_id}.webp"
      else
        if @resource.data.has_key? "spotlight_upload_Sketchfab-uid_tesim"
          uid = (@resource.uid || @resource.data["spotlight_upload_Sketchfab-uid_tesim"])
          begin
            model_info = RestClient.get("https://sketchfab.com/oembed?url=https://sketchfab.com/models/#{uid.to_s}")
            thumbnail_url = JSON.parse(model_info.body)["thumbnail_url"]
            if thumbnail_url.include?("placeholder") && Rails.application.config.active_job.queue_adapter != :inline
              Spotlight::ReindexJob.set(wait: 10.minutes).perform_later
            end
            thumbnail_url
          rescue RestClient::NotFound
            if Rails.application.config.active_job.queue_adapter != :inline
              Spotlight::ReindexJob.set(wait: 10.minutes).perform_later
            end
            "/uploads/spotlight/processing.png"
          end
        end
      end
    when "video"
      # Video thumbnail generation is handled by VideoThumbnailer gem
      # See app/uploaders/spotlight/featured_image_uploader and
      # https://github.com/teenacmathew/Video-Thumbnailer
      "/#{thumbnail_dir_path(@resource)}/video_thumb_#{@resource.file_name.split('.').first}.jpeg"
    when "audio"
      "/uploads/spotlight/audio.png"
    end
  end

  def riiif
    Riiif::Engine.routes.url_helpers
  end

  # Find the first resource in the compound_ids (attribute)
  def first_resource(compound_object)
    @first_resource ||= Spotlight::Resource.find(compound_object.compound_ids.first.split("-")[1])
  end

end