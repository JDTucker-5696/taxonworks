class RenameCeMd5 < ActiveRecord::Migration[4.2]
  def change
    rename_column :collecting_events, :verbatim_label_md5, :md5_of_verbatim_label
  end
end
