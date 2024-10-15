class RenameNudgeSmsConfirmationActivities < ActiveRecord::Migration[6.1]
  def up
    Activity.where(type: 'NudgeSmsConfirmationActivity').update_all(type: 'SmsConfirmationActivity')
  end

  def down
    Activity.where(type: 'SmsConfirmationActivity').update_all(type: 'NudgeSmsConfirmationActivity')
  end
end
