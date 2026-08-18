class RemoveModelIdAndUidFromSpotlightResources < ActiveRecord::Migration[7.2]

  def change
    remove_columns :spotlight_resources, :model_id, :uid, type: :string, null: false
  end

end
