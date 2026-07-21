module Spotlight
  module Resources
    module UploadControllerDecorator

      # OVERRIDE Spotlight v.4.7.0: Reindex items right away instead of deferring to Sidekiq
      # because users expect to see the item right away.
      def create
        super
        @resource.reindex
      end

      private

      # OVERRIDE Spotlight v.4.7.0: Create a featured image for compound objects, even if
      # there is no file attached. This is required for proper manifest generation.
      def build_resource
        @resource ||= begin
          super.tap do |resource|
            resource.build_upload(image: params[:resources_upload][:url]) if resource.upload.nil?
          end
        end
      end

      # @return[Array <String>] - the IDs of the child solr documents
      def compound_id_params
        if params.require(:resources_upload).permit(:compound_ids).present?
          JSON.parse(params.require(:resources_upload).permit(:compound_ids).fetch(:compound_ids))
        else
          []
        end
      end

      def resource_params
        params.require(:resources_upload).permit(data: data_param_keys).merge(compound_ids: compound_id_params)
      end

    end
  end
end
Spotlight::Resources::UploadController.prepend(Spotlight::Resources::UploadControllerDecorator)