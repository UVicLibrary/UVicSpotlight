# frozen_string_literal: true

# OVERRIDE Spotlight v.4.7.0:
# Set the masthead to display:true by default for newly-created mastheads
module Spotlight
  module MastheadDecorator
    extend ActiveSupport::Concern

    prepended do
      after_initialize :set_defaults, unless: :persisted?
    end

    def set_defaults
      self.display = true if self.display.nil?
    end

  end
end
Spotlight::Masthead.prepend(Spotlight::MastheadDecorator)