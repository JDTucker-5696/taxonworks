class CreateImports < ActiveRecord::Migration[4.2]
  def change
    create_table :imports do |t|
      t.string :name
      t.hstore :metadata

      t.timestamps
    end
  end
end
