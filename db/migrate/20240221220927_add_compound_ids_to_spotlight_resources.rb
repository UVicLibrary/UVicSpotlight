class AddCompoundIdsToSpotlightResources < ActiveRecord::Migration[5.2]
  def change
    add_column :spotlight_resources, :compound_ids, :string
  end
end
