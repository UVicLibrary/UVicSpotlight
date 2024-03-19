# frozen_string_literal: true

module SirTrevorRails
  module Blocks
    ##
    # Embed documents (using a special blacklight view configuration) and text block
    class SolrDocumentsEmbedBlock < SirTrevorRails::Blocks::SolrDocumentsBlock

      def use_mirador?
        # Use Mirador viewer by default
        value = send(:'use-mirador')
        value.present? ? ActiveModel::Type::Boolean.new.cast(value) : true
      end

    end
  end
end
