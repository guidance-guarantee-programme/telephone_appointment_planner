require 'rails_helper'

RSpec.describe AppointmentCreatedNotificationsJob do
  context 'when the guider is from TPAS' do
    it 'does nothing' do
      appointment = create(:appointment)

      expect(AppointmentMailer).not_to receive(:resource_manager_appointment_created)

      subject.perform(appointment)
    end
  end

  context 'when the guider is from CAS' do
    it 'does nothing' do
      appointment = create(:appointment, organisation: :cas)

      expect(AppointmentMailer).not_to receive(:resource_manager_appointment_created)

      subject.perform(appointment)
    end
  end

  context 'when the guider is from another organisation' do
    it 'enqueues email notifications for the organisation resource managers' do
      appointment = create(:appointment, organisation: :wallsend)

      expect(AppointmentMailer).to receive(:resource_manager_appointment_created)
        .with(appointment, 'rm@example.com')
        .and_return(double(deliver_later: true))

      subject.perform(appointment)
    end
  end
end
