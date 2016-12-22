require 'rails_helper'

RSpec.describe AssignmentActivity do
  describe '.from' do
    let(:appointment) { create(:appointment) }
    let(:user) { create(:user) }
    let(:audit) { appointment.audits.first }

    before { allow(PusherActivityNotificationJob).to receive(:perform_later) }

    subject { appointment.activities.first }

    context 'assignment' do
      it 'creates an assignment activity' do
        expect(subject).to be_a(described_class)

        expect(subject).to have_attributes(
          appointment: appointment,
          owner: appointment.guider,
          prior_owner: nil,
          message: "#{appointment.guider.name} was allocated a new appointment"
        )
      end
    end

    it 'pushes an activity update' do
      expect(PusherActivityNotificationJob)
        .to have_received(:perform_later)
        .with(appointment.guider_id, subject.id)
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
          prior_owner: prior_owner,
          owner: appointment.guider,
          appointment_id: appointment.id,
          message: "#{user.name} allocated this appointment to #{appointment.guider.name}"
        )
      end

      it 'pushes an activity update' do
        expect(PusherActivityNotificationJob)
          .to have_received(:perform_later)
          .with(appointment.guider_id, subject.id)
      end

      it 'pushes an activity update to the prior owner' do
        expect(PusherActivityNotificationJob)
          .to have_received(:perform_later)
          .with(prior_owner.id, subject.id)
      end
    end
  end
end
