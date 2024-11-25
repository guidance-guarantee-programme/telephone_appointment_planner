class CreateReleases < ActiveRecord::Migration[6.1]
  def change
    create_table :releases do |t|
      t.text :summary
      t.date :released_on

      t.timestamps
    end
  end
end
