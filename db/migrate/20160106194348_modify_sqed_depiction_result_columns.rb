class ModifySqedDepictionResultColumns < ActiveRecord::Migration
  def change
    remove_column :sqed_depictions, :result_boundaries
    add_column :sqed_depictions, :result_boundary_coordinates, :json
  end
end
