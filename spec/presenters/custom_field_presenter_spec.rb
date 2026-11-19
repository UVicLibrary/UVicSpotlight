# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CustomFieldPresenter, type: :presenter do
  let(:view_context) { controller.view_context }
  let(:options) { {} }
  let(:document) do
    SolrDocument.new(
      "parent_ids_ssim" => ["1-1"]
    )
  end

  describe '#field_value' do
    let(:relation) { ["https://example.com/related; https://example.com/other_link"] }
    let(:date) { ["1912-04-15"] }

    subject { described_class.new(view_context, document, field, options).render }

    context 'with one or more URLs' do
      let(:field) { Blacklight::Configuration::IndexField.new(key: "spotlight_upload_Relation_tesim") }
      let(:options) { { value: relation } }
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
          let(:options) { { value: ["https://example.com/related;https://example.com/other_link"] } }
          it 'renders the expected links' do
            expect(rendered).to have_link("https://example.com/related",
                                          href: "https://example.com/related", target: "_blank")
            expect(rendered).to have_link("https://example.com/other_link",
                                          href: "https://example.com/other_link", target: "_blank")
          end
        end
      end

      context 'with a single URL' do
        let(:options) { { value: ["https://example.com/related"] } }

        it 'renders the expected link' do
          expect(rendered).to have_link("https://example.com/related",
                                        href: "https://example.com/related", target: "_blank")
        end
      end
    end

    context 'with a parent field', verify_stubs: false do
      let(:field) { Blacklight::Configuration::IndexField.new(key: "parent_ids_ssim") }
      let(:options) { { value: "1-1" } }

      before do
        allow_any_instance_of(Blacklight::SearchService).to receive(:fetch).and_return(
          SolrDocument.new(id: "1-1", full_title_tesim: ["Parent Title"])
        )
        allow(view_context).to receive(:blacklight_config).and_return(Spotlight::Engine.blacklight_config)
        allow(view_context).to receive(:current_exhibit).and_return(Spotlight::Exhibit.new(slug: "test"))
      end

      it 'renders a link to the parent' do
        rendered = Capybara.string(subject)
        expect(rendered).to have_link("Parent Title",
                                      href: "/spotlight/test/catalog/1-1")
      end
    end

    context 'with a date field' do
      let(:field) { Blacklight::Configuration::IndexField.new(key: "spotlight_upload_dc_Date_tesi") }
      let(:options) { { value: date } }

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
      let(:options) { { value: ["Description"] } }

      it 'displays the value' do
        expect(subject).to eq "Description"
      end
    end
  end

  describe '#component' do
    let(:field) { Blacklight::Configuration::IndexField.new(key: "dummy_tesim") }
    subject { described_class.new(view_context, document, field, options).component }

    it { is_expected.to be CustomMetadataFieldComponent }
  end
end