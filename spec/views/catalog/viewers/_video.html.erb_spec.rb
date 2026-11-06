# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "catalog/viewers/_video", type: :view do

  let(:parent_doc) { SolrDocument.new(thumbnail_url_ssm: ["/parent_thumb"],
                                      upload_file_url_ssi: "/uploads/parent/parent.mp4") }

  let(:doc1) { SolrDocument.new(id: "1-1",
                                full_title_tesim: ['Title 1'],
                                thumbnail_url_ssm: ["/thumb/1"],
                                upload_file_url_ssi: "/uploads/1/1.mp4") }

  let(:doc2) { SolrDocument.new(id: "1-2",
                                full_title_tesim: ['Title 1'],
                                thumbnail_url_ssm: ["/thumb/2"],
                                upload_file_url_ssi: "/uploads/2/2.mp4") }

  context 'with a single-file object' do
    it 'renders the view' do
      render partial: "catalog/viewers/video", locals: { document: parent_doc }
      expect(rendered).to have_css('video.audioplayer', count: 1)
      # Preview image should be the item's thumbnail
      expect(rendered).to have_css('video.audioplayer[poster="/parent_thumb"]')
      expect(rendered).to match("style=\"display: block\"")
      expect(rendered).to have_css('source[src="/uploads/parent/parent.mp4"]')
    end
  end

  context 'with a compound object' do
    before do
      allow(parent_doc).to receive(:compound_object?).and_return true
      allow(parent_doc).to receive(:child_docs).and_return [doc1, doc2]
    end

    it 'renders the view' do
      render partial: "catalog/viewers/video", locals: { document: parent_doc }
      expect(rendered).to have_css('video.audioplayer', count: 2, visible: false)
      # Preview image should be the item's thumbnail
      expect(rendered).to have_css('video#audio_0[poster="/thumb/1"]')
      expect(rendered).to have_css('video#audio_1[poster="/thumb/2"]', visible: false)
      expect(rendered).to have_css('video#audio_0 source[src="/uploads/1/1.mp4"]')
      expect(rendered).to have_css('video#audio_1 source[src="/uploads/2/2.mp4"]', visible: false)
    end
  end

end