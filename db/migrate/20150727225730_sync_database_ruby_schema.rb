class SyncDatabaseRubySchema < ActiveRecord::Migration[4.2]
  def change
    # This migration does nothing other than forcing db/schema.rb to be re-built fixing spatial columns definitions
  end
end
