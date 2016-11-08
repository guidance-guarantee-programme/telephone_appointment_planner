require 'rails_helper'

RSpec.describe PusherActivityNotificationJob, '#perform' do
  let!(:recipient) do
    build_stubbed(:user)
  end

  let!(:activity) do
    build_stubbed(:activity, appointment: build_stubbed(:appointment))
  end

  subject do
    PusherActivityNotificationJob.perform_now(recipient, activity)
  end

  it 'notifies the recipient' do
    expect(Pusher).to receive(:trigger).with(
      'telephone_appointment_planner',
      "guider_activity_#{recipient.id}",
      body: anything
    ).ordered
    expect(Pusher).to receive(:trigger).ordered

    subject
  end

  it 'notifies anyone looking at the appointment' do
    expect(Pusher).to receive(:trigger).ordered
    expect(Pusher).to receive(:trigger).with(
      'telephone_appointment_planner',
      "appointment_activity_#{activity.appointment.id}",
      body: anything
    ).ordered

    subject
  end
end
