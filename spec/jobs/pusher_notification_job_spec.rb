require 'rails_helper'

RSpec.describe PusherNotificationJob, '#perform' do
  subject { described_class.new.perform(0, appointment) }

  context 'when the appointment is for today' do
    let(:appointment) { build_stubbed(:appointment, start_at: Time.zone.today) }

    it 'sends the push notification' do
      expect(Pusher).to receive(:trigger)

      subject
    end
  end

  context 'when the appointment is for another day' do
    let(:appointment) { build_stubbed(:appointment, start_at: Time.zone.tomorrow) }

    it 'does nothing' do
      expect(Pusher).to_not receive(:trigger)

      subject
    end
  end
end
