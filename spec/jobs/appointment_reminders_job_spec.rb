require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe AppointmentRemindersJob, '#perform' do
  before do
    allow(Appointment).to receive(:needing_reminder).and_return [appointment]
    allow(AppointmentMailer).to receive(:reminder).and_return(mailer_double)
    allow(mailer_double).to receive(:deliver_later)
  end

  let(:mailer_double) do
    double(:mailer)
  end

  let(:appointment) do
    create(
      :appointment,
      start_at: BusinessDays.from_now(20)
    )
  end

  let(:subject) do
    described_class.perform_now
  end

  it 'sends appointment emails' do
    subject

    expect(AppointmentMailer).to have_received(:reminder).with(appointment)
    expect(mailer_double).to have_received(:deliver_later).once
  end

  it 'creates a reminder activity' do
    subject

    activity = appointment.activities.first
    expect(activity).to be_a(ReminderActivity)
    expect(activity.user).to eq current_user
    expect(activity.owner).to eq appointment.guider
  end
end
# rubocop:enable Metrics/BlockLength
