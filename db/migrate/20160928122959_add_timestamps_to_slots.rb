class AddTimestampsToSlots < ActiveRecord::Migration[5.0]
  def change
    change_table :slots do |t|
      t.timestamps
    end
  end
end
