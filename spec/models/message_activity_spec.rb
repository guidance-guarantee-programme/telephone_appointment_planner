require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe MessageActivity do
  describe '.create' do
    before do
      allow(PusherActivityCreatedJob).to receive(:perform_later)
    end

    let(:user) { create(:user) }
    let(:appointment) { create(:appointment) }
    let(:message) { 'message' }
    let(:params) do
      {
        user:,
        owner: appointment.guider,
        appointment:,
        message:
      }
    end

    subject { described_class.create!(params) }

    it 'creates a create activity for the given appointment and message' do
      expect(subject).to be_a(described_class)

      expect(subject).to have_attributes(
        appointment_id: appointment.id,
        owner_id: appointment.guider.id,
        user_id: user.id,
        message:
      )
    end

    it 'pushes an activity update' do
      expect(PusherActivityCreatedJob).to have_received(:perform_later).with(subject.id)
    end
  end
end
# rubocop:enable Metrics/BlockLength
