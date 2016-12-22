require 'rails_helper'

RSpec.describe DropActivity, '.from' do
  let(:appointment) { create(:appointment) }

  before do
    allow(PusherActivityNotificationJob).to receive(:perform_later)
  end

  subject { described_class.from('drop', 'message', appointment) }

  it 'creates an activity entry' do
    expect(subject).to have_attributes(
      appointment_id: appointment.id,
      owner_id: appointment.guider_id,
      message: 'Drop - message'
    )
  end

  it 'notifies asynchronously' do
    expect(PusherActivityNotificationJob).to have_received(:perform_later).with(
      appointment.guider_id,
      subject.id
    )
  end
end
