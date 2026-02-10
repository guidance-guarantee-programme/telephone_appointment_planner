require 'rails_helper'

RSpec.describe PushGenesysAppointmentJob, '#perform' do
  context 'when the appointment is pushable' do
    let(:appointment) { double(:appointment, push_to_genesys?: true) }
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

  context 'when the appointment is not pushable' do
    it 'does not delegate to the genesys pusher' do
      appointment = double(:appointment, push_to_genesys?: false)

      described_class.perform_now(appointment)

      expect(Genesys::Push).not_to receive(:new)
    end
  end
end
