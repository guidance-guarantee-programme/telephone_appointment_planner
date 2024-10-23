require 'rails_helper'

RSpec.describe Api::V1::AppointmentCancellation, '#cancel' do # rubocop:disable Metrics/BlockLength
  context 'when the appointment is in the past' do
    it 'returns false' do
      @appointment = create(:appointment, start_at: Time.zone.parse('2024-10-01 13:00'))

      travel_to Time.zone.parse('2024-10-01 12:00') do
        expect(
          described_class.new(
            appointment_id: @appointment.id,
            date_of_birth: @appointment.date_of_birth,
            secondary_status: '32',
            other_reason: ''
          ).cancel
        ).to be_truthy
      end

      travel_to Time.zone.parse('2024-10-01 13:01') do
        expect(
          described_class.new(
            appointment_id: @appointment.id,
            date_of_birth: @appointment.date_of_birth,
            secondary_status: '32',
            other_reason: ''
          ).cancel
        ).to be_falsey
      end
    end
  end

  context 'when the appointment is PSG' do
    it 'returns false' do
      @appointment = create(:appointment, :due_diligence)

      expect(
        described_class.new(
          appointment_id: @appointment.id,
          date_of_birth: @appointment.date_of_birth,
          secondary_status: '32',
          other_reason: ''
        ).cancel
      ).to be_falsey
    end
  end

  context 'when the appointment matches the required criteria' do
    it 'returns true' do
      @appointment = create(:appointment)

      expect(
        described_class.new(
          appointment_id: @appointment.id,
          date_of_birth: @appointment.date_of_birth,
          secondary_status: '32',
          other_reason: ''
        ).cancel
      ).to be_truthy
    end
  end

  context 'when the appointment cannot be matched' do
    it 'returns false' do
      @appointment = create(:appointment, status: :cancelled_by_customer_sms)

      expect(
        described_class.new(
          appointment_id: @appointment.id,
          date_of_birth: @appointment.date_of_birth,
          secondary_status: '32',
          other_reason: ''
        ).cancel
      ).to be_falsey
    end
  end
end
