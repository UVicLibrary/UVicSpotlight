# frozen_string_literal: true

module SirTrevorRails
  module Blocks
    ##
    # Embed documents (using a special blacklight view configuration) and text block
    class AudioWithImageBlock < SirTrevorRails::Blocks::SolrDocumentsBlock
      include Textable
      include Displayable
      attr_reader :solr_helper

      def use_viewer?
        self.use_viewer
      end

      def documents
        @documents ||= begin
                         documents = doc_ids.map { |id| SolrDocument.find(id)}
                         documents
                       end
      end

      def doc_ids
        items.map { |v| v[:id] }
      end

      def audio
        documents.find { |doc| doc.file_type == "audio" }
      end

      def image
        documents.find { |doc| doc.file_type == "image" }
      end

    end
  end
end
