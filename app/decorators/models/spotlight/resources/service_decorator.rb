module Spotlight
  module Resources
    module IiifServiceDecorator

      def manifests
        @manifests ||= if manifest? && @url.include?("vault.library.uvic.ca")
                         [create_vault_iiif_manifest(object)]
                       elsif manifest?
                         [create_iiif_manifest(object)]
                       else
                         build_collection_manifest.to_a
                       end
      end

      class << self
        def iiif_response(url)
          begin
            if url.include?("vault.library.uvic.ca")
              conn = Faraday.new(url, { ssl: {verify:false}})
              conn.get.body
            else
              Faraday.get(url).body
            end
          rescue Faraday::Error::ConnectionFailed, Faraday::TimeoutError => e
            Rails.logger.warn("HTTP GET for #{url} failed with #{e}")
            {}.to_json
          end
        end
      end

      def create_vault_iiif_manifest(manifest, collection = nil)
        Spotlight::Resources::VaultIiifManifest.new(url: manifest['@id'], manifest: manifest, collection: collection)
      end

      def build_collection_manifest
        return to_enum(:build_collection_manifest) unless block_given?

        if collection? && @url.include?("vault.library.uvic.ca")
          self_manifest = create_vault_iiif_manifest(object)
        elsif collection?
          self_manifest = create_iiif_manifest(object)
        end
        yield self_manifest

        (object.try(:manifests) || []).each do |manifest|
          yield create_vault_iiif_manifest(self.class.new(manifest['@id']).object, self_manifest)
          # yield create_iiif_manifest(self.class.new(manifest['@id']).object, self_manifest)
        end
      end

    end
  end
end
#Spotlight::Resources::IiifService.prepend(Spotlight::Resources::IiifServiceDecorator)