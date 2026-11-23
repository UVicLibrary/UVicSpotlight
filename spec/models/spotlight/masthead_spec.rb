# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Spotlight::Masthead do
  subject { Spotlight::Masthead.new }

  describe 'newly initialized object' do
    it 'sets display:true by default' do
      expect(subject.display).to be true
    end
  end
end