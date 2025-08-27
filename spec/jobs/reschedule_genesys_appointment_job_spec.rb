require 'rails_helper'

RSpec.describe RescheduleGenesysAppointmentJob, '#perform' do # rubocop:disable Metrics/BlockLength
  context 'when the appointment is already pushed to genesys' do
    let(:appointment) { double(:appointment, genesys_operation_id?: true, genesys_pushable_guider?: true) }
    let(:genesys_reschedule) { instance_double(Genesys::Reschedule) }

    before do
      allow(Genesys::Reschedule).to receive(:new).with(appointment).and_return(genesys_reschedule)
    end

    it 'delegates to the genesys rescheduler' do
      allow(genesys_reschedule).to receive(:call)

      described_class.perform_now(appointment)

      expect(genesys_reschedule).to have_received(:call)
    end
  end

  context 'when the appointment is rescheduled away from genesys' do
    let(:appointment) { double(:appointment, genesys_operation_id?: true, genesys_pushable_guider?: false) }
    let(:genesys_push) { instance_double(Genesys::Push) }

    before do
      allow(Genesys::Push).to receive(:new).with(appointment).and_return(genesys_push)
    end

    it 'delegates to the genesys pusher for cancellation' do
      allow(genesys_push).to receive(:call)

      described_class.perform_now(appointment)

      expect(genesys_push).to have_received(:call)
    end
  end

  context 'when the appointment is rescheduled from a non-genesys to genesys agent' do
    let(:appointment) { double(:appointment, genesys_operation_id?: false, genesys_pushable_guider?: true) }
    let(:genesys_push) { instance_double(Genesys::Push) }

    before do
      allow(Genesys::Push).to receive(:new).with(appointment).and_return(genesys_push)
    end

    it 'delegates to the genesys pusher' do
      allow(genesys_push).to receive(:call)

      described_class.perform_now(appointment)

      expect(genesys_push).to have_received(:call)
    end
  end

  context 'when the appointment is none of the above' do
    let(:appointment) { double(:appointment, genesys_operation_id?: false, genesys_pushable_guider?: false) }

    it 'does not delegate to genesys' do
      expect(described_class.perform_now(appointment)).to be_falsey
    end
  end
end
