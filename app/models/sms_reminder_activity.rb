class SmsReminderActivity < Activity
  def pusher_notify_user_ids
    appointment.guider_id
  end
end
