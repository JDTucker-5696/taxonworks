class FixDataAttributeType < ActiveRecord::Migration[4.2]
  def change
    change_column :data_attributes, :attribute_subject_type, :string
  end
end
