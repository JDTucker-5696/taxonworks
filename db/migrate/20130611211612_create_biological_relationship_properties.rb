class CreateBiologicalRelationshipProperties < ActiveRecord::Migration[4.2]
  def change
    create_table :biological_relationship_properties do |t|
      t.string :type
      t.references :biological_property, index: false 
      t.references :biological_relationship, index: false 

      t.timestamps
    end
  end
end
