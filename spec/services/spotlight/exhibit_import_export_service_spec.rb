# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Spotlight::ExhibitImportExportService do

  describe '#serialize_featured_image' do
    subject { described_class.new(Spotlight::Exhibit.new).send(:serialize_featured_image, 0) }

    context 'when image does not exist' do
      it 'rescues ActiveRecord::RecordNotFound exception' do
        expect(subject).to eq({ image: "Image not found for ID: 0" })
      end
    end

    context 'with an image' do
      let(:image) { Spotlight::FeaturedImage.new }
      let(:uploader) { Spotlight::FeaturedImageUploader.new }
      let(:file) { CarrierWave::SanitizedFile.new(tempfile: "path/to/file.jpg", content_type: "image/jpeg") }

      before do
        allow(Spotlight::FeaturedImage).to receive(:find).and_return(image)
        allow(image).to receive(:image).and_return(uploader)
        allow(uploader).to receive(:file).and_return(file)
      end

      it 'returns a hash with a file path' do
        expect(subject[:image]).to include("filename": "file.jpg",
                                           "content_type": "image/jpeg",
                                           "filepath": "path/to/file.jpg")
      end
    end
  end

  describe '#as_json' do
    let(:exhibit) { Spotlight::Exhibit.new }

    before do
      allow(exhibit).to receive(:friendly_id).and_return("friendly_id")
      allow(described_class).to receive(:serialization_pipeline).and_return([])
    end

    it 'writes to a file and returns the filepath' do
      expect { described_class.new(exhibit).as_json }
        .to change { Dir.glob("#{described_class::EXPORT_FILE_DIR}/*").count }.by(1)
      expect(described_class.new(exhibit).as_json).to match(/friendly_id(.*?)_export\.json/)
    end
  end

end