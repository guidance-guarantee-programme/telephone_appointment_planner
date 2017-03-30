require 'rails_helper'

RSpec.describe CustomerUpdateActivity do
  describe '.from' do
    before do
      allow(PusherActivityCreatedJob).to receive(:perform_later)
    end

    let(:appointment) { create(:appointment) }
    let(:message) { 'message' }
    subject { described_class.from(appointment, message) }

    it 'creates a create activity for the given appointment and message' do
      expect(subject).to be_a(described_class)

      expect(subject).to have_attributes(
        appointment_id: appointment.id,
        owner_id: appointment.guider.id,
        message: message
      )
    end

    it 'pushes an activity update' do
      expect(PusherActivityCreatedJob)
        .to have_received(:perform_later)
        .with(appointment.guider_id, subject.id)
    end
  end
end
