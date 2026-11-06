# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "catalog/_metadata_pages", type: :view do
  around(:example) do |example|
    without_partial_double_verification do
      example.call
    end
  end

  before do
    assign(:child_docs,
       [
         SolrDocument.new(id: "1-1", full_title_tesim: ['Title 1']),
         SolrDocument.new(id: "1-2", full_title_tesim: ['Title 2'])
       ]
    )

    allow(view).to receive(:blacklight_config).and_return(Spotlight::Engine.blacklight_config)
    allow(view).to receive(:download_item_path).and_return("download path")
    allow(view).to receive(:exhibit_edit_link).and_return('<a class="pull-right btn btn-primary">Edit</a>'.html_safe)
    allow(view).to receive(:current_exhibit).and_return(Spotlight::Exhibit.new)

    stub_template "catalog/_metadata_fields.html.erb" => "<div><dt>Field Name:</dt><dd>Value</dd></div>"
  end

  context 'without edit permissions' do
    before do
      allow(view).to receive(:can?).and_return(false)
    end

    it 'renders the correct metadata elements' do
      render
      expect(rendered).to have_css('.metadata-page#page_0[data-canvas-id="1-1"]')
      expect(rendered).to have_css('.metadata-page#page_1[data-canvas-id="1-2"]', visible: false)
      expect(rendered).to have_link('Download Current File', href: "download path", count: 2, visible: false)
      expect(rendered).to include('Title 1')
      expect(rendered).to include('Title 2')
    end

    it 'does not render the edit button' do
      render
      expect(rendered).not_to have_css('a.pull-right.btn.btn-primary', text: 'Edit')
    end
  end

  context 'with edit permissions' do
    before do
      allow(view).to receive(:can?).and_return(true)
    end

    it 'renders the correct metadata elements' do
      render
      expect(rendered).to have_css('.metadata-page#page_0[data-canvas-id="1-1"]')
      expect(rendered).to have_css('.metadata-page#page_1[data-canvas-id="1-2"]', visible: false)
      expect(rendered).to have_link('Download Current File', href: "download path", count: 2, visible: false)
      expect(rendered).to include('Title 1')
      expect(rendered).to include('Title 2')
    end

    it 'renders the edit button' do
      render
      expect(rendered).to have_css('a.pull-right.btn.btn-primary', text: 'Edit')
    end
  end
end