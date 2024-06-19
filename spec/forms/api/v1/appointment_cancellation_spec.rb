require 'rails_helper'

RSpec.describe Api::V1::AppointmentCancellation, '#cancel' do
  context 'when the appointment matches the required criteria' do
    it 'returns true' do
      @appointment = create(:appointment)

      expect(
        described_class.new(appointment_id: @appointment.id, date_of_birth: @appointment.date_of_birth).cancel
      ).to be_truthy
    end
  end

  context 'when the appointment cannot be matched' do
    it 'returns false' do
      @appointment = create(:appointment, status: :cancelled_by_customer_sms)

      expect(
        described_class.new(appointment_id: @appointment.id, date_of_birth: @appointment.date_of_birth).cancel
      ).to be_falsey
    end
  end
end
