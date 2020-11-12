require 'rails_helper'

RSpec.describe BslCustomerExitPollJob, '#perform_now' do
  it 'sends the exit poll email and logs an activity' do
    appointment = build_stubbed(:appointment, bsl_video: true)

    expect(AppointmentMailer).to receive(:bsl_customer_exit_poll).with(appointment)
    expect(BslCustomerExitPollActivity).to receive(:from).with(appointment)

    described_class.perform_now(appointment)
  end
end
