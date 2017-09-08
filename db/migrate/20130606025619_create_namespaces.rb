class CreateNamespaces < ActiveRecord::Migration[4.2]
  def change
    create_table :namespaces do |t|
      t.string :institution
      t.string :name
      t.string :short_name

      t.timestamps
    end
  end
end
