require 'rails_helper'

RSpec.describe AppointmentRescheduledNotificationsJob do
  context 'when the guider is from TPAS' do
    it 'does nothing' do
      appointment = create(:appointment, organisation: :tpas)

      expect(AppointmentMailer).not_to receive(:resource_manager_appointment_rescheduled)

      subject.perform(appointment)
    end
  end

  context 'when the guider is from NI' do
    it 'sends to permitted resource managers' do
      appointment = create(:appointment, organisation: :ni)

      # excluded due to the UID
      create(:resource_manager, :ni, uid: '6f338640-808d-0133-2100-36ff48a3bf62', email: 'bad@example.com')

      expect(AppointmentMailer).to receive(:resource_manager_appointment_rescheduled)
        .with(appointment, 'rm@example.com')
        .and_return(double(deliver_later: true))

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
