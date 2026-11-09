# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "catalog/viewers/_pdf", type: :view do
  let(:doc) { SolrDocument.new(id: "1-1",
                                full_title_tesim: ['Title 1'],
                                thumbnail_url_ssm: ["/thumb/1"],
                                upload_file_url_ssi: "/uploads/1/1.pdf") }

  context 'with a single-file object' do
    it 'renders the view' do
      render partial: "catalog/viewers/pdf", locals: { document: doc }
      expect(rendered).to have_css('iframe[src="/uploads/1/1.pdf"]')
    end
  end

end