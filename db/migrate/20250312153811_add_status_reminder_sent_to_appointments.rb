class AddStatusReminderSentToAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :status_reminder_sent, :boolean
  end
end
