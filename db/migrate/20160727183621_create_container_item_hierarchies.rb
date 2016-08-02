class CreateContainerItemHierarchies < ActiveRecord::Migration
  def change
    create_table :container_item_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :container_item_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "container_item_anc_desc_idx"

    add_index :container_item_hierarchies, [:descendant_id],
      name: "container_item_desc_idx"
  end
end
