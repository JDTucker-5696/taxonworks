class ClassifiedAs < ActiveRecord::Migration[4.2]
  def change
    add_column :taxon_names, :cached_classified_as, :string
  end
end
