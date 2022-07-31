require 'rails_helper'

RSpec.describe BslCustomerExitPollJob, '#perform_now' do
  context 'when no mobile number is present' do
    it 'sends the exit poll email and logs an activity' do
      appointment = build_stubbed(:appointment, bsl_video: true, mobile: '')

      expect(AppointmentMailer).to receive(:bsl_customer_exit_poll).with(appointment)
      expect(BslCustomerExitPollActivity).to receive(:from).with(appointment)

      described_class.perform_now(appointment)
    end
  end

  context 'when a mobile number is present' do
    it 'sends the exit poll SMS and logs an activity' do
      appointment = create(:appointment, bsl_video: true, start_at: Time.zone.parse('2022-06-30 13:00 UTC'))

      client = double(Notifications::Client, send_sms: true)
      allow(Notifications::Client).to receive(:new).and_return(client)

      expect(client).to receive(:send_sms).with(
        phone_number: '07715 930 444',
        template_id: BslCustomerExitPollJob::BSL_EXIT_POLL_SMS_TEMPLATE_ID,
        reference: appointment.to_param,
        personalisation: {
          date: '1:00pm, 30 Jun 2022 (BST)'
        }
      )

      described_class.perform_now(appointment)
    end
  end
end
