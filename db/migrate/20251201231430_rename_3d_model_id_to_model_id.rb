class Rename3dModelIdToModelId < ActiveRecord::Migration[7.0]

  def change
    rename_column :spotlight_resources, :"3d_model_id", :model_id
  end

end
