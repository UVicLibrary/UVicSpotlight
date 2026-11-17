# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CustomIndexShowPresenter do

  describe '#field_presenter', type: :presenter do
    let(:view_context) { controller.view_context }
    let(:document) { SolrDocument.new }
    let(:field) { Blacklight::Configuration::IndexField.new(key: "dummy_tesim") }
    let(:options) { { value: "dummmy val" } }

    subject { described_class.new(document, view_context).field_presenter(field, options) }

    it 'initializes a CustomFieldPresenter' do
      expect(subject).to be_a(CustomFieldPresenter)
    end
  end

end