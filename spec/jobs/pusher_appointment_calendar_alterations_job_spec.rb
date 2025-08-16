require 'rails_helper'

RSpec.describe PusherAppointmentCalendarAlterationsJob, '#perform' do # rubocop:disable Metrics/BlockLength
  let(:appointment) { create(:appointment, start_at: Time.zone.parse('2024-05-15 13:00')) }

  before { allow(Pusher).to receive(:trigger) }

  subject { described_class.new.perform(appointment) }

  context 'when something other than `start_at` changed' do
    it 'triggers once for the current `start_at`' do
      subject

      expect(Pusher).to have_received(:trigger).with(
        'telephone_appointment_planner',
        '2024-05-15-14a48488-a42f-422d-969d-526e30922fe4',
        refresh: true
      )
    end
  end

  context 'when the `start_at` changed' do
    it 'triggers for the prior `start_at` as well' do
      appointment.update!(
        start_at: '2024-05-16 13:00',
        end_at: '2024-05-16 14:10',
        rescheduling_reason: Appointment::OFFICE_RESCHEDULED
      )

      subject

      expect(Pusher).to have_received(:trigger).with(
        'telephone_appointment_planner',
        '2024-05-15-14a48488-a42f-422d-969d-526e30922fe4',
        refresh: true
      )

      expect(Pusher).to have_received(:trigger).with(
        'telephone_appointment_planner',
        '2024-05-16-14a48488-a42f-422d-969d-526e30922fe4',
        refresh: true
      )
    end
  end
end
