# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PageLinksHelper, type: :helper do

  let(:exhibit) { Spotlight::Exhibit.new(slug: "exhibit") }
  let(:home_page) { Spotlight::HomePage.new(title: 'Home') }
  let(:feature_pages) do
    [ Spotlight::FeaturePage.new(title: 'First Page'),
      Spotlight::FeaturePage.new(title: 'Second Page'),
      hidden_page]
  end
  let(:about_pages) { [Spotlight::AboutPage.new(title: 'About')] }
  let(:hidden_page) { Spotlight::FeaturePage.new(title: 'Hidden') }

  before do
    exhibit.home_page = home_page
    exhibit.feature_pages = feature_pages
    exhibit.about_pages = about_pages
    allow(exhibit).to receive(:id).and_return("exhibit-id")

    ([home_page] + feature_pages).each do |page|
      allow(page).to receive(:exhibit).and_return(exhibit)
      allow(page).to receive(:id).and_return(page.title.parameterize)
      allow(helper).to receive(:can?).with(:read, page).and_return true
    end
    allow(helper).to receive(:can?).with(:read, hidden_page).and_return false

    helper.extend(Spotlight::Engine.routes.url_helpers)
  end

  context 'on the homepage' do
    let(:page) { home_page }

    describe '#previous_page' do
      it 'returns nil' do
        expect(helper.previous_page(page)).to be_nil
      end
    end

    describe '#next_page' do
      it 'returns the first feature page' do
        expect(helper.next_page(page)).to be(feature_pages[0])
      end
    end
  end

  context 'on an about page' do
    let(:page) { about_pages[0] }

    describe '#previous_page' do
      it 'returns nil' do
        expect(helper.previous_page(page)).to be_nil
      end
    end

    describe '#next_page' do
      it 'returns the first feature page' do
        expect(helper.next_page(page)).to be_nil
      end
    end
  end

  context 'on the first feature page' do
    let(:page) { feature_pages[0] }

    describe '#previous_page' do
      it 'returns the homepage' do
        expect(helper.previous_page(page)).to be home_page
      end
    end

    describe '#next_page' do
      it 'returns the last feature page' do
        expect(helper.next_page(page)).to be feature_pages[1]
      end
    end
  end

  context 'on the last feature page' do
    let(:page) { feature_pages[1] }

    describe '#previous_page' do
      it 'returns the first feature page' do
        expect(helper.previous_page(page)).to be feature_pages[0]
      end
    end

    describe '#next_page' do
      it 'returns nil (not the hidden page)' do
        expect(helper.next_page(page)).to be_nil
      end
    end
  end

  describe 'links to pages' do
    let(:page) { feature_pages[0] }

    describe '#link_to_previous_page' do
      subject { helper.link_to_previous_page(page) }
      before { home_page.title = "Here I am, a really long title that should be truncated" }

      it 'renders the correct link' do
        expect(subject).to match("href=\"/spotlight/exhibit/feature/home\"")
      end

      it 'shortens really long titles' do
        expect(subject).to match("&lt; Here I am, a really long title that should be...")
      end
    end

    describe '#link_to_next_page' do
      subject { helper.link_to_next_page(page) }
      before { feature_pages[1].title = "Here I am, a really long title that should be truncated" }

      it 'renders the correct link' do
        expect(subject).to match("href=\"/spotlight/exhibit/feature/second-page\"")
      end

      it 'shortens really long titles' do
        expect(subject).to match("Here I am, a really long title that should be... &gt;")
      end
    end
  end
end