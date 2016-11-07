require 'rails_helper'

RSpec.describe AuditActivity do
  describe '.from' do
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

    it 'creates an audit activity from the given audit' do
      expect(subject).to be_a(described_class)

      expect(subject).to have_attributes(
        user_id: audit.user_id,
        owner_id: @appointment.guider.id,
        appointment_id: @appointment.id,
        message: 'first name, email, and phone'
      )
    end
  end
end
