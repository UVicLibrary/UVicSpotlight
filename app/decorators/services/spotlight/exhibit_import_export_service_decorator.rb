# frozen_string_literal: true

# OVERRIDE Spotlight v.4.7.0:
# - Instead of error-ing out on missing/deleted featured images or
#   missing/deleted image.images, add a "Image not found" message to the export.
# - Write exhibit exports to a tmpfile so we can stream it later instead of reading
#   the entire export into memory
# - Record an uploaded file's filepath (instead of writing its contents to a binary string?!)
#   to prevent out-of-memory errors

# TO DO:
# - Override #deserialize_featured_image to read file contents from a file path
#   instead of a binary string
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

    # OVERRIDE: Handle missing/deleted images and write file path instead of the
    # binary contents of the entire file
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
            # This used to include content: Base64.encode64(file.read)
            filename: file.filename, content_type: file.content_type, filepath: file.file
          }
        }
      end
      image.as_json(except: %i[id image]).merge(img || {}).deep_symbolize_keys
    end

    def attach_attachments(json)
      return json unless json[:attachments]

      json[:attachments].each do |attachment|
        a = exhibit.attachments.find(attachment[:id])
        file = a.file.file

        if a.file?
          attachment[:file] = {
            filename: file.filename,
            content_type: file.content_type,
            # content: Base64.encode64(file.read)
            filepath: file.file
          }
        else
          attachment[:file] = {
            image: "No file found for ID: #{a.id}"
          }
        end
        attachment.delete(:id)
      end

      json
    end
  end

  # TO DO: Override #deserialize_featured_image to read file contents from a
  # file path instead of a binary string

end
Spotlight::ExhibitImportExportService.prepend(Spotlight::ExhibitImportExportServiceDecorator)