# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Spotlight::FieldMetadata do
  subject { described_class.new(exhibit, repository, blacklight_config) }

  let(:exhibit) { Spotlight::Exhibit.new }
  let(:repository) { CatalogController.blacklight_config.repository }
  let(:blacklight_config) { CatalogController.blacklight_config }

  describe '#facet_fields' do
    it 'includes query facet fields (default Spotlight filters them out)' do
      expect(subject.facet_fields["compound_ids_ssim"]['query']).to be_a(Hash)
    end
  end

end