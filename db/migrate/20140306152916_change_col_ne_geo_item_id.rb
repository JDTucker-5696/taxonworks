class ChangeColNeGeoItemId < ActiveRecord::Migration[4.2]
  def change

    remove_column :geographic_areas, :ne_geo_item_id

    add_column :geographic_areas, :ne_geo_item_id, :integer

  end
end
