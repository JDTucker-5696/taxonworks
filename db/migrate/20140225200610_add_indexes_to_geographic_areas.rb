class AddIndexesToGeographicAreas < ActiveRecord::Migration[4.2]
  def change

    add_index :geographic_areas, :lft
    add_index :geographic_areas, :rgt
    add_index :geographic_areas, :parent_id
    add_index :geographic_areas, :name

  end
end
