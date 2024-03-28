Spotlight::FeaturedImageUploader.class_eval do
  # Requirements for making thumbnails from videos
  include VideoThumbnailer

  def cache_dir
    "tmp/cache"
  end

  def png_name for_file, version_name, format
    %Q{#{version_name}_#{for_file.chomp(File.extname(for_file))}.#{format}}
  end

  version :video_thumb, if: :is_video?

  version :video_thumb do
    process generate_thumb:[{:quality => 5, :time_frame => "00:0:10", :file_extension => "jpeg" }]
    def full_filename for_file
      png_name for_file, version_name, "jpeg"
    end
  end

  def is_video?(file)
    file.filename.include?("mp4") rescue false# || file.content_type.include?("ogg")
  end

end