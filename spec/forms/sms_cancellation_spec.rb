require 'rails_helper'

RSpec.describe SmsCancellation do
  include ActiveJob::TestHelper

  subject { described_class.new(source_number: '07715 930 455', message: 'Cancel.', schedule_type: 'pension_wise') }

  describe 'validation' do
    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires the `source_number`' do
      subject.source_number = ''

      expect(subject).to be_invalid
    end

    it 'requires the `schedule_type`' do
      subject.schedule_type = ''

      expect(subject).to be_invalid
    end

    it 'requires the correct `message` for cancellation' do
      subject.message = 'Please cancel my appointment.'
      expect(subject).to be_invalid

      subject.message = "'Cancel'"
      expect(subject).to be_valid
    end
  end

  describe '#call' do
    let(:appointment) { create(:appointment, mobile: '07715930455', status: :complete) }

    before { allow(SmsCancellationFailureJob).to receive(:perform_later) }

    context 'when the underlying appointment is not pending' do
      it 'does not attempt to cancel and notifies the customer' do
        subject.call

        expect(appointment.reload).to be_complete

        expect(SmsCancellationFailureJob).to have_received(:perform_later).with(
          '07715 930 455',
          'pension_wise'
        )
      end
    end

    context 'when the underlying appointment is due diligence' do
      let(:appointment) { create(:appointment, :due_diligence, mobile: '07715930455') }

      it 'does not attempt to cancel' do
        subject.call

        expect(appointment.reload).to be_pending
      end
    end
  end
end
