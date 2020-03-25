require 'rails_helper'

RSpec.describe AppointmentCancelledNotificationsJob do
  context 'when the appointment has a TPAS guider' do
    it 'ensures the resource managers are not alerted by email' do
      appointment = create(:appointment)

      expect(AppointmentMailer).not_to receive(:resource_manager_appointment_cancelled)

      subject.perform(appointment)
    end
  end

  context 'when the appointment is not for TPAS' do
    it 'alerts the resource managers by email' do
      appointment = create(:appointment, organisation: :wallsend)

      expect(AppointmentMailer).to receive(:resource_manager_appointment_cancelled)
        .with(appointment, 'rm@example.com')
        .and_return(double(deliver_later: true))

      subject.perform(appointment)
    end
  end
end
