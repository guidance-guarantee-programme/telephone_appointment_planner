require 'rails_helper'

RSpec.describe AppointmentStatusReminderJob, '#perform' do
  before do
    allow(Appointment).to receive(:needing_status_reminder).and_return [appointment]
    allow(AppointmentMailer).to receive(:guider_status_reminder).and_return(mailer_double)
    allow(mailer_double).to receive(:deliver_later)
  end

  let(:mailer_double) { double(:mailer) }
  let(:appointment) { create(:appointment) }

  let(:subject) { described_class.perform_now }

  it 'sends pending status reminder emails' do
    subject

    expect(AppointmentMailer).to have_received(:guider_status_reminder).with(appointment)
    expect(mailer_double).to have_received(:deliver_later).once

    expect(appointment.reload).to be_status_reminder_sent
  end
end
