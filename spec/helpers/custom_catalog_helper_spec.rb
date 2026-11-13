# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CustomCatalogHelper, type: :helper do

  let(:document) { SolrDocument.new(
    "spotlight_upload_dc_description_tesim" => ["Description"],
    "spotlight_upload_Relation_tesim" => relation,
    "spotlight_upload_dc_Date_tesi" => date,
    "parent_ids_ssim" => ["1-1"],
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
  let(:relation) { ["https://example.com/related; https://example.com/other_link"] }
  let(:date) { ["1912-04-15"] }

  let(:presenter) { Blacklight::ShowPresenter.new(document, CatalogController) }

  # Stub a placeholder for field. We will set the key later in specs so we can
  # retrieve the value we want by calling document[key].
  let(:field) { Blacklight::Configuration::IndexField.new }

  before do
    allow(presenter).to receive(:field_value).with(field).and_return(presenter.document.fetch(field.key, nil))
  end

  describe '#field_value' do
    subject { helper.field_value(presenter, field) }

    context 'with one or more URLs' do
      let(:field) { Blacklight::Configuration::IndexField.new(key: "spotlight_upload_Relation_tesim") }
      let(:rendered) { Capybara.string(subject) }

      context 'with multiple URLs' do
        context 'with spaces and semicolons' do
          it 'renders the expected links' do
            expect(rendered).to have_link("https://example.com/related",
                                          href: "https://example.com/related", target: "_blank")
            expect(rendered).to have_link("https://example.com/other_link",
                                          href: "https://example.com/other_link", target: "_blank")
          end
        end

        context 'with semicolons but without spaces' do
          let(:relation) { ["https://example.com/related;https://example.com/other_link"] }
          it 'renders the expected links' do
            expect(rendered).to have_link("https://example.com/related",
                                          href: "https://example.com/related", target: "_blank")
            expect(rendered).to have_link("https://example.com/other_link",
                                          href: "https://example.com/other_link", target: "_blank")
          end
        end
      end

      context 'with a single URL' do
        let(:relation) { ["https://example.com/related"] }

        it 'renders the expected link' do
          expect(rendered).to have_link("https://example.com/related",
                                        href: "https://example.com/related", target: "_blank")
        end
      end
    end

    context 'with a parent field', verify_stubs: false do
      let(:field) { Blacklight::Configuration::IndexField.new(key: "parent_ids_ssim") }

      before do
        allow_any_instance_of(Blacklight::SearchService).to receive(:fetch).and_return(
          SolrDocument.new(id: "1-1", full_title_tesim: ["Parent Title"])
        )
        allow(helper).to receive(:blacklight_config).and_return(Spotlight::Engine.blacklight_config)
        allow(helper).to receive(:current_exhibit).and_return(Spotlight::Exhibit.new(slug: "test"))
      end

      it 'renders a link to the parent' do
        rendered = Capybara.string(subject)
        expect(rendered).to have_link("Parent Title",
                                      href: "/spotlight/test/catalog/1-1", target: "_blank")
      end
    end

    context 'with a date field' do
      let(:field) { Blacklight::Configuration::IndexField.new(key: "spotlight_upload_dc_Date_tesi") }

      context 'with a valid EDTF date' do
        it 'displays the humanized EDTF date' do
          expect(subject).to eq "April 15, 1912"
        end
      end

      context 'with a non-EDTF date' do
        let(:date) { ["04/15/1912"] }

        it 'gracefully displays the text value' do
          expect(subject).to eq "04/15/1912"
        end
      end
    end

    context 'with a text field' do
      let(:field) { Blacklight::Configuration::IndexField.new(key: "spotlight_upload_dc_description_tesim") }

      it 'displays the value' do
        expect(subject).to eq "Description"
      end
    end
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