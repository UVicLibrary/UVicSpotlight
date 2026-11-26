# frozen_string_literal: true

# OVERRIDE Spotlight v.4.7.0:
# - Instead of error-ing out on missing/deleted featured images or
#   missing/deleted image.images, add a "Image not found" message to the export.
# - Write exhibit exports to a tmpfile so we can stream it later instead of reading
#   the entire export into memory
module Spotlight
  module ExhibitImportExportServiceDecorator

    EXPORT_FILE_DIR = Rails.application.credentials.export_file_path || Rails.root.join("tmp","exports").to_s

    # OVERRIDE: write to a tmpfile so we can call stream the file using
    # #send_file instead of #send_data. This prevents the app from crashing
    # for large exhibits with many pages/items.
    # @return [String] - the relative path to the JSON export
    def as_json(*_args)
      FileUtils.mkdir_p(EXPORT_FILE_DIR)
      tmpfile = "#{@exhibit.friendly_id}_#{Time.now.to_s.parameterize}_export.json"
      File.open("#{EXPORT_FILE_DIR}/#{tmpfile}", 'w+') do |file|
        export_json = self.class.serialization_pipeline.inject({}) do |memo, step|
          method(step).call(memo)
        end
        file.write(JSON.pretty_generate(export_json))
      end
      "#{EXPORT_FILE_DIR}/#{tmpfile}"
    end

    private

    # OVERRIDE: Handle missing/deleted images
    def serialize_featured_image(id)
      begin
        image = Spotlight::FeaturedImage.find(id)
        file = image.image.file
      rescue ActiveRecord::RecordNotFound
        image = {}
        img = { image: "Image not found for ID: #{id}" }
      end

      if file
        img = {
          image: {
            filename: file.filename, content_type: file.content_type, content: Base64.encode64(file.read)
          }
        }
      end
      image.as_json(except: %i[id image]).merge(img || {}).deep_symbolize_keys
    end
  end

end
Spotlight::ExhibitImportExportService.prepend(Spotlight::ExhibitImportExportServiceDecorator)