require 'rails_helper'

RSpec.describe AssignmentActivity do
  describe '.from' do
    before do
      allow(PusherActivityNotificationJob).to receive(:perform_later)
      @appointment = create(:appointment)
    end

    let(:audit) { @appointment.audits.first }
    subject { @appointment.activities.first }

    context 'assignment' do
      it 'creates an assignment activity' do
        expect(subject).to be_a(described_class)

        expect(subject).to have_attributes(
          appointment: @appointment,
          owner: @appointment.guider,
          prior_owner: nil,
          message: 'assigned'
        )
      end
    end

    it 'pushes an activity update' do
      expect(PusherActivityNotificationJob)
        .to have_received(:perform_later)
        .with(@appointment.guider, subject)
    end

    context 'reassignment' do
      before do
        @prior_owner = @appointment.guider
        @appointment.guider = create(:guider)
        @appointment.save!
      end

      it 'creates an assignment activity' do
        expect(subject).to be_a(described_class)

        expect(subject).to have_attributes(
          prior_owner: @prior_owner,
          owner: @appointment.guider,
          appointment_id: @appointment.id,
          message: 'reassigned'
        )
      end

      it 'pushes an activity update' do
        expect(PusherActivityNotificationJob)
          .to have_received(:perform_later)
          .with(@appointment.guider, subject)
      end

      it 'pushes an activity update to the prior owner' do
        expect(PusherActivityNotificationJob)
          .to have_received(:perform_later)
          .with(@prior_owner, subject)
      end
    end
  end
end
