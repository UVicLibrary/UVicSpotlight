# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "catalog/_metadata_fields", type: :view do
  around(:example) do |example|
    without_partial_double_verification do
      example.call
    end
  end

  let(:field1) { Blacklight::Configuration::IndexField.new(key: "spotlight_upload_Relation_tesim", label: "Relation") }
  let(:field2) { Blacklight::Configuration::IndexField.new(key: "dont_render_me_tesim", label: "Don't render me") }
  let(:fields) { [
    [field1.key, field1],
    [field2.key, field2]
  ] }

  let(:document) { SolrDocument.new(
    "spotlight_upload_Relation_tesim" => "https://example.com",
    "dont_render_me_tesim" => "You can't see me"
  ) }

  let(:presenter) { double(CustomFieldPresenter) }

  before do
    allow(view).to receive(:should_render_field?).with(field1, document).and_return true
    allow(view).to receive(:should_render_field?).with(field2, document).and_return false
    allow(view).to receive(:document_presenter).and_return(presenter)
    allow(presenter).to receive(:field_value).with(field1).and_return(
      '<a href="https://www.example.com" target="_blank">https://www.example.com</a>'
    )
  end

  describe 'render' do
    it 'renders the correct elements' do
      render partial: "catalog/metadata_fields", locals: { fields: fields, document: document }
      expect(rendered).to have_css("div.metadata-field dt.blacklight-spotlight_upload_relation_tesim[onclick='hideShow(event)']")
      # Dropdown arrow icon
      expect(rendered).to have_css("i.fa-chevron-down")
      expect(rendered).to have_css("div.metadata-field dd.blacklight-spotlight_upload_relation_tesim")
      expect(rendered).not_to have_css("dt.blacklight-dont_render_me_tesim")
      expect(rendered).not_to have_css("dd.blacklight-dont_render_me_tesim")
    end

    it 'sanitizes links' do
      render partial: "catalog/metadata_fields", locals: { fields: fields, document: document }
      expect(rendered).to match('<a href="https://www.example.com" target="_blank">https://www.example.com</a>')
    end
  end
end