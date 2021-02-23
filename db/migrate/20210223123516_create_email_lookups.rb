class CreateEmailLookups < ActiveRecord::Migration[6.0]
  def change
    create_table :email_lookups do |t|
      t.string :organisation_id, null: false, unique: true
      t.string :email, null: false

      t.timestamps
    end
  end
end
