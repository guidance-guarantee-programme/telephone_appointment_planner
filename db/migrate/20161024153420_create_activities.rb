class CreateActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :activities do |t|
      t.integer :appointment_id, null: false, index: true
      t.integer :user_id
      t.string :message, null: false
      t.string :type, null: false, index: true

      t.timestamps
    end
  end
end
