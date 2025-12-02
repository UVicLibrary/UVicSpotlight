class Add3dModelIdToResource < ActiveRecord::Migration[7.0]

  def change
    add_column :spotlight_resources, :"3d_model_id", :string
  end

end
