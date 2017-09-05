class CreateContents < ActiveRecord::Migration[4.2]
  def change
    create_table :contents do |t|
      t.text :text
      t.references :otu, index: true
      t.integer :topic_id
      t.string :type

      t.timestamps
    end
  end
end
