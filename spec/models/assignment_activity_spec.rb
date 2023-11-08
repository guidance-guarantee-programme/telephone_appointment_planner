require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe AssignmentActivity do
  describe '.from' do
    let(:appointment) { create(:appointment) }
    let(:user) { create(:user) }
    let(:audit) { appointment.audits.first }

    before { allow(PusherActivityCreatedJob).to receive(:perform_later) }

    subject { appointment.activities.first }

    context 'assignment' do
      it 'creates an assignment activity' do
        expect(subject).to be_a(described_class)

        expect(subject).to have_attributes(
          appointment:,
          owner: appointment.guider,
          prior_owner: nil,
          message: 'assigned'
        )
      end
    end

    it 'pushes an activity update' do
      expect(PusherActivityCreatedJob).to have_received(:perform_later).with(subject.id)
    end

    context 'reassignment' do
      let!(:prior_owner) { appointment.guider }

      before do
        appointment.guider = create(:guider)
        appointment.save!

        subject.update!(user_id: user.id)
      end

      it 'creates an assignment activity' do
        expect(subject).to be_a(described_class)

        expect(subject).to have_attributes(
          prior_owner:,
          owner: appointment.guider,
          appointment_id: appointment.id,
          message: 'reassigned'
        )
      end

      it 'pushes an activity update' do
        expect(PusherActivityCreatedJob).to have_received(:perform_later).with(subject.id)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
