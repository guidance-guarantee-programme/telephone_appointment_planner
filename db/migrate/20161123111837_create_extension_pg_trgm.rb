class CreateExtensionPgTrgm < ActiveRecord::Migration[5.0]
  def change
    execute 'CREATE EXTENSION pg_trgm'
  end
end
