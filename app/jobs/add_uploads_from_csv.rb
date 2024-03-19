# encoding: utf-8
module Spotlight
  ##
  # Process a CSV upload into new Spotlight::Resource::Upload objects
  class AddUploadsFromCSV < ActiveJob::Base
    queue_as :default
    require 'down/wget'

    after_perform do |job|
      csv_data, exhibit, user = job.arguments
      Spotlight::IndexingCompleteMailer.documents_indexed(csv_data, exhibit, user).deliver_now
    end

    def perform(csv_data, exhibit, _user)
      encoded_csv(csv_data).each do |row|
        url = row.delete('url')
        next unless url.present?

        url = url.sub("http://", "https://")
        # To Do: Check if there is actually a file at the URL

        # Use the IIIF Manifest importer if it's a vault item
        if url.include?(".library.uvic.ca") && url.include?("manifest")
          if url.end_with?("manifest")
            url += ".json"
          end
          # Need file name for resource.file_type method
          resource = Spotlight::Resources::IiifHarvester.new( url: url, exhibit_id: exhibit.id, file_name: "default.jpg", data: row)
          resource.save_and_index
        else
          resource = Spotlight::Resources::Upload.new(
              data: row,
              exhibit: exhibit
          )
          if url.include?(".library.uvic.ca/download")
            temp_file = Down::Wget.download(url, :no_check_certificate)
            resource.file_name = temp_file.original_filename
            placeholder = Spotlight::FeaturedImage.create image: temp_file
            resource.upload = placeholder
          else
            resource.build_upload(remote_image_url: url) unless url == '~'
          end
          resource.save_and_index

        end
      end
    end

    private
    
    def encoded_csv(csv)
      csv.map do |row|
        row.map do |label, column|
          [label, column.encode('UTF-8', invalid: :replace, undef: :replace, replace: "\uFFFD")] if column.present?
        end.compact.to_h
      end.compact
    end
  end
end
