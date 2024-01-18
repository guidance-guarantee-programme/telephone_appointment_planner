require 'rails_helper'

RSpec.describe CustomerUpdateJob, '#perform' do
  include ActiveJob::TestHelper

  it 'guards against no customer email' do
    appointment = double(email?: false)

    described_class.new.perform(appointment, 'message')

    assert_no_enqueued_jobs
    expect(CustomerUpdateActivity.count).to be_zero
  end

  context 'when the email is janky' do
    it 'logs an activity' do
      appointment = create(:appointment)

      allow(AppointmentMailer).to receive(:updated).and_raise(Net::SMTPSyntaxError.new(nil))

      described_class.new.perform(appointment, CustomerUpdateActivity::UPDATED_MESSAGE)

      expect(appointment.activities.first).to be_a(DropActivity)
    end
  end

  context 'when the appointment is not pending' do
    context 'when an appointment updated attempt is made' do
      it 'does not send the notification or log an activity' do
        appointment = create(:appointment, status: :cancelled_by_customer_sms)

        expect(AppointmentMailer).to_not receive(:updated)

        described_class.new.perform(appointment, CustomerUpdateActivity::UPDATED_MESSAGE)

        expect(CustomerUpdateActivity.count).to be_zero
      end
    end
  end
end
