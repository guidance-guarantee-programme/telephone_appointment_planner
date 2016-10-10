class CreateAppointments < ActiveRecord::Migration[5.0]
  def change
    create_table :appointments do |t|
      t.integer :user_id, null: false
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false

      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email
      t.string :phone, null: false
      t.string :mobile
      t.string :year_of_birth
      t.string :memorable_word, null: false
      t.text :notes
      t.boolean :opt_out_of_market_research, null: false, default: false
    end
  end
end
