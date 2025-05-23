require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe DueDiligenceReferenceNumberJob, '#perform' do
  context 'when the number is unique' do
    it 'updates the appointment URN' do
      @appointment = create(
        :appointment,
        :due_diligence,
        start_at: Time.zone.parse('2021-09-14'),
        status: :complete
      )

      described_class.perform_now(@appointment)

      expect(@appointment.reload.unique_reference_number).to be_present
    end
  end

  context 'when the generated number is not unique' do
    include ActiveJob::TestHelper

    it 'raises an error thus retrying the job' do
      allow_any_instance_of(DueDiligenceReferenceNumber).to receive(:call).and_return('12345614092021')
      allow_any_instance_of(DueDiligenceReferenceNumber).to receive(:call).and_return('12345615092021')

      @appointment = create(
        :appointment,
        :due_diligence,
        start_at: Time.zone.parse('2021-09-14'),
        status: :complete,
        unique_reference_number: '12345614092021'
      )

      @duplicate = create(
        :appointment,
        :due_diligence,
        start_at: Time.zone.parse('2021-09-14'),
        status: :complete
      )

      # ensures clashes will retry a suitable number of times to generate a unique reference
      perform_enqueued_jobs do
        described_class.perform_now(@duplicate)
      end

      expect(@duplicate.reload.unique_reference_number).to eq('12345615092021')
    end
  end
end
# rubocop:enable Metrics/BlockLength
