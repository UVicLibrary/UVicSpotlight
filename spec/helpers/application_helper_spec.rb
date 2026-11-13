# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do

  describe 'included modules' do
    it 'includes required modules' do
      expect(helper.class.ancestors).to include(BlacklightHelper, SpotlightHelper, Spotlight::MainAppHelpers)
    end
  end

  describe '#exhibit_stylesheet_link_tag' do
    let(:exhibit) { double(Spotlight::Exhibit) }

    before do
      allow(helper).to receive(:current_exhibit).and_return(exhibit)
      allow(exhibit).to receive(:theme).and_return('')
      allow(helper).to receive(:stylesheet_link_tag)
    end

    it 'does not blow up our logs with warnings', verify_stubs: false do
      without_partial_double_verification do
        expect(Rails.logger).not_to receive(:warn)
        helper.exhibit_stylesheet_link_tag('theme')
      end
    end
  end
end