class ThumbnailService
  include VideoThumbnailer

  require 'fileutils'
  require 'rest_client'

  def initialize(resource)
    @resource = resource
  end

  # @return [String] - the path to the created thumbnail
  def create_thumbnail
    case @resource.file_type
    when "image"
      Spotlight::RiiifService.thumbnail_url(@resource.upload_id)
    when "pdf"
      pdf_name = File.basename(@resource.file_name, '.pdf')
      # Run vips from the command line
      `vips thumbnail #{full_thumbnail_dir_path}/#{@resource.file_name} #{full_thumbnail_dir_path}/#{pdf_name}-thumb.jpg 500x`
      # Return the thumbnail path for indexing
      "/#{thumbnail_dir_path(@resource)}/#{pdf_name}-thumb.jpg"
    when "model"
      model_id = @resource.data['spotlight_upload_3d_model_url_tesim'].split("/").last.split("?").first
      "#{@resource.class::MODEL_BASE_URL}/server/previews/entity/#{model_id}.webp"
    when "video"
      # Video thumbnail generation is handled by VideoThumbnailer gem
      # See app/uploaders/spotlight/featured_image_uploader and
      # https://github.com/teenacmathew/Video-Thumbnailer
      video_thumb_path(@resource)
    when "audio"
      "/core/audio.png"
    when "compound object"
      child = @resource.first_child
      case child.file_type
      when "image"
        Spotlight::RiiifService.thumbnail_url(child.upload_id)
      when "video"
        video_thumb_path(child)
      when "audio"
        "/core/audio.png"
      end
    end
  end

  private

  def video_thumb_path(resource)
    "/#{thumbnail_dir_path(resource)}/video_thumb_#{resource.file_name.split('.').first}.jpeg"
  end

  # The absolute file path to the upload dir, needed for vips to generate a pdf thumbnail
  def full_thumbnail_dir_path
    Rails.root.join("public", thumbnail_dir_path(@resource))
  end

  def thumbnail_dir_path(resource)
    # "uploads/spotlight/featured_image/image/#{resource.upload_id}"
    resource.upload.image.store_dir
  end
end