require 'rails_helper'

RSpec.describe AppointmentRescheduledAwayNotificationsJob do # rubocop:disable Metrics/BlockLength
  context 'when the previous guider is from CAS' do
    it 'sends to the alias' do
      appointment = create(:appointment, previous_guider: create(:guider, :cas))

      expect(AppointmentMailer).to receive(:resource_manager_appointment_rescheduled_away)
        .with(appointment, 'CAS_PWBooking@cas.org.uk')
        .and_return(double(deliver_later: true))

      subject.perform(appointment)
    end
  end

  context 'when the previous guider is from TPAS' do
    it 'does nothing' do
      appointment = create(:appointment, previous_guider: create(:guider, :tpas))

      expect(AppointmentMailer).not_to receive(:resource_manager_appointment_rescheduled_away)

      subject.perform(appointment)
    end
  end

  context 'when the previous guider is from another organisation' do
    it 'sends notifications to the resource managers' do
      create(:resource_manager, :north_tyneside)
      appointment = create(:appointment, previous_guider: create(:guider, :north_tyneside))

      expect(AppointmentMailer).to receive(:resource_manager_appointment_rescheduled_away)
        .with(appointment, 'rm@example.com')
        .and_return(double(deliver_later: true))

      subject.perform(appointment)
    end
  end
end
