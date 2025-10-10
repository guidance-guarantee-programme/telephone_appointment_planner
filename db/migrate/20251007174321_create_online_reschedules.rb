class CreateOnlineReschedules < ActiveRecord::Migration[8.0]
  def change
    create_table :online_reschedules do |t|
      t.belongs_to :appointment, index: true
      t.belongs_to :previous_guider, index: true
      t.datetime :previous_start_at, null: false

      t.timestamps
    end
  end
end
