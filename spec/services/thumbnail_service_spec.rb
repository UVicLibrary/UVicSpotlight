# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ThumbnailService do

  let(:resource) { double(Spotlight::Resource) }
  let(:image) { double(Spotlight::FeaturedImage) }
  let(:upload) { double(Spotlight::FeaturedImageUploader) }
  let(:service) { described_class.new(resource) }

  before do
    # Set up associations between objects. resource.upload should be a featured image,
    # and resource.upload.image should be a featured image uploader
    allow(resource).to receive(:upload_id).and_return(0)
    allow(resource).to receive(:upload).and_return(image)
    allow(image).to receive(:image).and_return(upload)
    allow(upload).to receive(:store_dir).and_return("uploads/spotlight/featured_image/image/#{resource.upload_id}")
  end

  describe '#create_thumbnail' do
    subject { service.create_thumbnail }

    context 'with an image' do
      before { allow(resource).to receive(:file_type).and_return("image") }

      it { is_expected.to eq "/images/0/full/!400,400/0/default.jpg" }
    end

    context 'with an audio file' do
      before { allow(resource).to receive(:file_type).and_return("audio") }

      it { is_expected.to eq "/core/audio.png" }
    end

    context 'with a video' do
      before do
        allow(resource).to receive(:file_type).and_return("video")
        allow(resource).to receive(:file_name).and_return("test.mp4")
      end

      it { is_expected.to eq "/uploads/spotlight/featured_image/image/0/video_thumb_test.jpeg" }
    end

    context 'with a pdf' do
      before do
        allow(resource).to receive(:file_type).and_return("pdf")
        allow(resource).to receive(:file_name).and_return("test.pdf")
        allow(service).to receive(:`)
      end

      it { is_expected.to eq "/uploads/spotlight/featured_image/image/0/test-thumb.jpg" }
    end

    context 'with a 3D model' do
      before do
        allow(resource).to receive(:file_type).and_return("model")
        allow(resource).to receive(:class).and_return(Spotlight::Resource)
        allow(resource).to receive(:data).and_return({ 'spotlight_upload_3d_model_url_tesim' => '123' })
      end

      it { is_expected.to eq "https://kompakkt.de/server/previews/entity/123.webp" }
    end

    context 'with a compound object' do
      let(:child) { double(Spotlight::Resource) }

      before do
        allow(resource).to receive(:file_type).and_return("compound object")
        allow(resource).to receive(:first_child).and_return(child)
        allow(child).to receive(:upload_id).and_return(1)
      end

      context 'made of images' do
        before { allow(child).to receive(:file_type).and_return("image") }

        it { is_expected.to eq "/images/1/full/!400,400/0/default.jpg" }
      end

      context 'made of videos' do
        before do
          allow(child).to receive(:file_type).and_return("video")
          allow(child).to receive(:file_name).and_return("child_test.mp4")

          allow(child).to receive(:upload).and_return(image)
          allow(upload).to receive(:store_dir).and_return("uploads/spotlight/featured_image/image/#{child.upload_id}")
        end

        it { is_expected.to eq "/uploads/spotlight/featured_image/image/1/video_thumb_child_test.jpeg" }
      end

      context 'made of audio files' do
        before { allow(child).to receive(:file_type).and_return("audio") }

        it { is_expected.to eq "/core/audio.png" }
      end
    end
  end

end