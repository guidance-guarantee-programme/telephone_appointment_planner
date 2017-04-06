require 'rails_helper'

RSpec.describe DroppedSummaryDocumentActivity do
  describe '.from' do
    before do
      allow(PusherActivityCreatedJob).to receive(:perform_later)
    end

    let(:appointment) { create(:appointment) }
    let(:message) { 'message' }
    subject { described_class.from(appointment) }

    it 'creates a dropped activity for the given appointment' do
      expect(subject).to be_a(described_class)

      expect(subject).to have_attributes(
        appointment_id: appointment.id,
        owner_id: appointment.guider.id,
        message: DroppedSummaryDocumentActivity::MESSAGE
      )
    end

    it 'pushes an activity update' do
      expect(PusherActivityCreatedJob)
        .to have_received(:perform_later)
        .with(appointment.guider_id, subject.id)
    end
  end
end
