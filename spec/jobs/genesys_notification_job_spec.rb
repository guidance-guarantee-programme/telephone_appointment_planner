require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe GenesysNotificationJob, '#perform' do
  context 'when the event does not contain an `operationId`' do
    it 'does not create a `GenesysProcessedActivity`' do
      described_class.perform_now('{}')

      expect(GenesysProcessedActivity.count).to eq(0)
    end
  end

  context 'when the event contains an `operationId`' do
    context 'when an associated appointment cannot be located' do
      it 'does not create a `GenesysProcessedActivity`' do
        described_class.perform_now('{ "eventBody": { "operationId": "deadbeef" }}')

        expect(GenesysProcessedActivity.count).to eq(0)
      end
    end

    context 'when an associated appointment is located in the context of a rescheduling' do
      let(:appointment) { create(:appointment, genesys_rescheduling_operation_id: SecureRandom.hex) }
      let(:data) do
        {
          eventBody: {
            operationId: appointment.genesys_rescheduling_operation_id,
            result: {
              generationResults: {
                failed:
              }
            }
          }
        }
      end
      let(:failed) { false }
      let(:push_double) { double(Genesys::Push) }

      before do
        allow(Genesys::Push).to receive(:new).with(appointment).and_return(push_double)
        allow(push_double).to receive(:call)
      end

      context 'when the generation result is successful' do
        it 'pushes the rescheduled appointment' do
          described_class.perform_now(data.to_json)

          expect(GenesysProcessedActivity.count).to eq(0)

          expect(push_double).to have_received(:call)
        end
      end

      context 'when the generation result is a failure' do
        let(:failed) { true }

        it 'creates the correct activity and message' do
          described_class.perform_now(data.to_json)

          expect(push_double).to_not have_received(:call)
        end
      end
    end

    context 'when an associated appointment is located in the context of a regular push' do
      let(:appointment) { create(:appointment, genesys_operation_id: SecureRandom.hex) }
      let(:data) do
        {
          eventBody: {
            operationId: appointment.genesys_operation_id,
            result: {
              generationResults: {
                failed:
              }
            }
          }
        }
      end
      let(:failed) { false }

      context 'when the generation result is successful' do
        it 'creates the correct activity and message' do
          described_class.perform_now(data.to_json)

          expect(GenesysProcessedActivity.count).to eq(1)
          expect(GenesysProcessedActivity.last).to have_attributes(
            appointment_id: appointment.id,
            message: 'The appointment was synchronised with Genesys'
          )
        end
      end

      context 'when the generation result is a failure' do
        let(:failed) { true }

        it 'creates the correct activity and message' do
          described_class.perform_now(data.to_json)

          expect(GenesysProcessedActivity.count).to eq(1)
          expect(GenesysProcessedActivity.last).to have_attributes(
            appointment_id: appointment.id,
            message: 'The appointment could not be synchronised with Genesys'
          )
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
