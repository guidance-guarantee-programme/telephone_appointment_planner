require 'rails_helper'

RSpec.describe AppointmentCancelledNotificationsJob do
  %i(tpas ni).each do |provider|
    context "when the guider is from #{provider}" do
      it 'does nothing' do
        appointment = create(:appointment, organisation: provider)

        expect(AppointmentMailer).not_to receive(:resource_manager_appointment_cancelled)

        subject.perform(appointment)
      end
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
