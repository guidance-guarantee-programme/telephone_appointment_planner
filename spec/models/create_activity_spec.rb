require 'rails_helper'

RSpec.describe CreateActivity do
  describe '.from' do
    before do
      allow(PusherActivityNotificationJob).to receive(:perform_later)
      # this will trigger the `after_audit` hook on `Appointment`
      @appointment = create(:appointment)
    end

    let(:audit) { @appointment.audits.last }
    subject { @appointment.activities.last }

    it 'creates a create activity from the given audit' do
      expect(subject).to be_a(described_class)

      expect(subject).to have_attributes(
        user_id: audit.user_id,
        appointment_id: @appointment.id,
        owner_id: @appointment.guider.id
      )
    end

    it 'pushes an activity update' do
      expect(PusherActivityNotificationJob)
        .to have_received(:perform_later)
        .with(@appointment.guider_id, subject.id)
    end
  end
end
