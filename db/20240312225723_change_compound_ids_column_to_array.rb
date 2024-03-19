class ChangeCompoundIdsColumnToArray < ActiveRecord::Migration[6.0]

  def change
    change_column :spotlight_resources, :compound_ids, :array, default: []
  end

end
