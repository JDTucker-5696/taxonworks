class ChgContainerLabelsModifiedBy2UpdatedBy < ActiveRecord::Migration[4.2]
  def change
    rename_column :container_labels, :modified_by_id, :updated_by_id
  end
end
