# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SolrDocument do
  let(:document) {
    SolrDocument.new(
      'id' => '1-1',
      'spotlight_upload_3d_model_id_tesim' => ['abcdefg'],
      'resource_file_type_ssi' => 'image',
      'upload_file_url_ssi' => '/spotlight/uploads/images/23/file.jpg',
      'thumbnail_url_ssm' => '/spotlight/thumbnails/23/file.jpg'
    )
  }

  let(:compound_object) {
    SolrDocument.new(
      'resource_file_type_ssi' => 'compound object',
      'compound_ids_ssim' => ['1-1','1-2'],
      'child_file_type_ssi' => 'image'
    )
  }

  describe '#model_id' do
    subject { document.model_id }
    it { is_expected.to eq 'abcdefg' }
  end

  describe '#file_type' do
    subject { document.file_type }
    it { is_expected.to eq 'image' }
  end

  describe '#resource' do
    before do
      allow(Spotlight::Resource).to receive(:find).with(1).and_return(Spotlight::Resource.new(id: 1))
    end

    it 'returns a resource object' do
      expect(document.resource).to be_a Spotlight::Resource
      expect(document.resource.id).to eq 1
    end
  end

  describe '#upload_url' do
    subject { document.upload_url }
    it { is_expected.to be '/spotlight/uploads/images/23/file.jpg' }
  end

  describe '#compound_ids' do
    context 'with a compound object' do
      it 'returns an array of compound ids' do
        expect(compound_object.compound_ids).to eq ['1-1','1-2']
      end
    end

    context 'with a single-file object' do
      it 'returns an empty array' do
        expect(document.compound_ids).to eq []
      end
    end
  end

  describe '#child_file_type' do
    context 'with a compound object' do
      subject { compound_object.child_file_type }
      it { is_expected.to eq 'image' }
    end

    context 'with a single-file object' do
      subject { document.child_file_type }
      it { is_expected.to be_nil }
    end
  end

  describe '#compound_object?' do
    context 'with a compound object' do
      subject { compound_object.compound_object? }
      it { is_expected.to eq true }
    end

    context 'with a single-file object' do
      subject { document.compound_object? }
      it { is_expected.to eq false }
    end
  end

  describe '#child_docs' do
    context 'with a compound object' do
      let(:search_results) { double }

      before do
        allow_any_instance_of(Blacklight::SearchService).to receive(:search_results).and_return(search_results)
        allow(search_results).to receive(:docs).and_return [SolrDocument.new(id: "1-2"), SolrDocument.new(id: "1-1")]
      end

      it 'returns an ordered array of Solr documents' do
        results = compound_object.child_docs
        expect(results).to be_a Array
        expect(results[0].id).to eq "1-1"
        expect(results[1].id).to eq "1-2"
      end
    end

    context 'with a single-file object' do
      it 'returns an empty array' do
        expect(document.child_docs).to eq []
      end
    end
  end
end