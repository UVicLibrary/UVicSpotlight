module Spotlight
  module ExhibitsControllerDecorator

    def show
      respond_to do |format|
        format.json do
          authorize! :export, @exhibit
          send_file Spotlight::ExhibitImportExportService.new(@exhibit).as_json,
                    type: 'application/json',
                    disposition: 'attachment',
                    filename: "#{@exhibit.friendly_id}-export.json"
        end
      end
    end

  end
end
Spotlight::ExhibitsController.prepend(Spotlight::ExhibitsControllerDecorator)