class RenameCollectionObjectDeaccession < ActiveRecord::Migration[4.2]
  def change
    remove_column :collection_objects, :deaccession_at
    add_column :collection_objects, :deaccessioned_at, :date
  end
end
