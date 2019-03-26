FactoryBot.define do
  factory :activity, class: 'AuditActivity' do
    user
    appointment
    owner { create(:guider) }
    message { 'did a thing to a thing' }
    type { 'AuditActivity' }

    factory :reminder_activity, class: 'ReminderActivity' do
      owner { appointment.guider }
      type { 'ReminderActivity' }
    end
  end
end
