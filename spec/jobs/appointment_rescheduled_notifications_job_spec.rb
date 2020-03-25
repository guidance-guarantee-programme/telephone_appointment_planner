require 'rails_helper'

RSpec.describe AppointmentRescheduledNotificationsJob do
  context 'when the guider is from TPAS' do
    it 'does not send notifications' do
      appointment = create(:appointment)

      expect(AppointmentMailer).not_to receive(:resource_manager_appointment_rescheduled)

      subject.perform(appointment)
    end
  end

  context 'when the guider is from another organisation' do
    it 'sends notifications to the resource managers' do
      appointment = create(:appointment, organisation: :wallsend)

      expect(AppointmentMailer).to receive(:resource_manager_appointment_rescheduled)
        .with(appointment, 'rm@example.com')
        .and_return(double(deliver_later: true))

      subject.perform(appointment)
    end
  end
end
