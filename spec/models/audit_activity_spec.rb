require 'rails_helper'

RSpec.describe AuditActivity do
  describe '.from' do
    before do
      allow(PusherActivityCreatedJob).to receive(:perform_later)
    end

    context 'with updated fields' do
      before do
        @appointment = create(:appointment).tap do |a|
          # this will trigger the `after_audit` hook on `Appointment`
          a.update(
            first_name: 'Dave Jones',
            email: 'dj@dj.com',
            phone: '07715 930 455'
          )
        end
      end

      let(:audit) { @appointment.audits.first }
      subject { @appointment.activities.first }

      it 'creates an audit activity with the fields' do
        expect(subject).to be_a(described_class)

        expect(subject).to have_attributes(
          user_id: audit.user_id,
          owner_id: @appointment.guider.id,
          appointment_id: @appointment.id,
          message: 'first name, email, and phone'
        )
      end

      it 'pushes an activity update' do
        expect(PusherActivityCreatedJob)
          .to have_received(:perform_later)
          .with(@appointment.guider_id, subject.id)
      end
    end

    context 'guider_id is the only updated field' do
      before do
        @appointment = create(:appointment).tap do |a|
          a.update(guider: create(:guider))
        end
      end

      it 'does not create an audit activity' do
        @appointment.activities.each do |activity|
          expect(activity).to_not be_a(described_class)
        end
      end
    end
  end
end
