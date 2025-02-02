class RenameSmsReminderFailureActivities < ActiveRecord::Migration[6.1]
  def up
    Activity.where(type: 'SmsReminderFailureActivity').update_all(type: 'SmsFailureActivity')
  end

  def down
    Activity.where(type: 'SmsFailureActivity').update_all(type: 'SmsReminderFailureActivity')
  end
end
