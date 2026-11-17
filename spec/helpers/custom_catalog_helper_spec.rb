# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CustomCatalogHelper, type: :helper do

  let(:document) { SolrDocument.new(
    "thumbnail_url_ssm" => ["/images/1/full/!400,400/0/default.jpg"],
    "upload_file_url_ssi" => "/path/to/upload.mp4"
  ) }
  let(:compound_object) {
    SolrDocument.new({
      "compound_ids_ssim" => ["1-2","1-3"],
      "resource_file_type_ssi" => "compound object",
      "child_file_type_ssi" => "image"
    })
  }

  let(:presenter) { Blacklight::ShowPresenter.new(document, CatalogController) }

  # Stub a placeholder for field. We will set the key later in specs so we can
  # retrieve the value we want by calling document[key].
  let(:field) { Blacklight::Configuration::IndexField.new }

  before do
    allow(presenter).to receive(:field_value).with(field).and_return(presenter.document.fetch(field.key, nil))
  end

  describe '#render_download_item_link' do
    # Just a dummy to prevent an error
    let(:field) { Blacklight::Configuration::IndexField.new(key: "foo") }

    context 'with a single file object' do
      subject { helper.render_download_item_link(document) }

      context 'that is an image' do
        before { allow(document).to receive(:file_type).and_return "image" }

        it 'returns a IIIF path to the full size image' do
          rendered = Capybara.string(subject)
          expect(rendered).to have_link("Download item", href: "/images/1/full/full/0/default.jpg", target: "_blank")
        end
      end

      context 'that is not an image' do
        before { allow(document).to receive(:file_type).and_return "video" }

        it 'returns the upload path' do
          rendered = Capybara.string(subject)
          expect(rendered).to have_link("Download item", href: "/path/to/upload.mp4", target: "_blank")
        end
      end
    end

    context 'with a compound object' do
      subject { helper.render_download_item_link(compound_object) }

      it { is_expected.to eq '' }
    end
  end

  describe '#media_display' do
    subject { helper.media_display(document) }

    context 'with an image' do
      before { allow(document).to receive(:file_type).and_return "image" }

      it 'renders the image viewer' do
        expect(helper).to receive(:render)
                          .with("catalog/viewers/image", { document: document })
        subject
      end
    end

    context 'with a video' do
      before { allow(document).to receive(:file_type).and_return "video" }

      it 'renders the image viewer' do
        expect(helper).to receive(:render)
                            .with("catalog/viewers/video", { document: document })
        subject
      end
    end

    context 'with an audio file' do
      before { allow(document).to receive(:file_type).and_return "audio" }

      it 'renders the image viewer' do
        expect(helper).to receive(:render)
                            .with("catalog/viewers/audio", { document: document })
        subject
      end
    end

    context 'with a pdf' do
      before { allow(document).to receive(:file_type).and_return "pdf" }

      it 'renders the image viewer' do
        expect(helper).to receive(:render)
                            .with("catalog/viewers/pdf", { document: document })
        subject
      end
    end

    context 'with a compound object' do
      subject { helper.media_display(compound_object) }

      it 'renders the image viewer' do
        expect(helper).to receive(:render)
                            .with("catalog/viewers/image", { document: compound_object })
        subject
      end
    end
  end
end