require 'rails_helper'

RSpec.describe AssignmentActivity do
  describe '.from' do
    before do
      @appointment = create(:appointment)
    end

    let(:audit) { @appointment.audits.first }
    subject { @appointment.activities.first }

    it 'creates an assignment activity' do
      expect(subject).to be_a(described_class)

      expect(subject).to have_attributes(
        appointment: @appointment,
        owner: @appointment.guider,
        prior_owner: nil,
        message: 'assigned'
      )
    end

    context 'appointment is reassigned' do
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
    end
  end
end
