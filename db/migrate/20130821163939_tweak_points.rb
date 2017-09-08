class TweakPoints < ActiveRecord::Migration[4.2]
  def change
    remove_columns :geographic_items, :point, :multi_point
    add_column :geographic_items, :point, :st_point, :geographic => true
    add_column :geographic_items, :multi_point, :multi_point, :geographic => true
  end
end
