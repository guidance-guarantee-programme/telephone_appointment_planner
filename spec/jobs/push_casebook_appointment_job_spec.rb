require 'rails_helper'

RSpec.describe PushCasebookAppointmentJob, '#perform' do
  context 'when the appointment is pushable' do
    let(:appointment) { double(:appointment, push_to_casebook?: true) }
    let(:casebook_push) { instance_double(Casebook::Push) }

    before do
      allow(Casebook::Push).to receive(:new).with(appointment).and_return(casebook_push)
    end

    it 'delegates to the casebook pusher' do
      allow(casebook_push).to receive(:call)

      described_class.perform_now(appointment)

      expect(casebook_push).to have_received(:call)
    end

    context 'when a casebook error occurs' do
      it 'notifies bugsnag' do
        allow(casebook_push).to receive(:call).and_raise(Casebook::ApiError)
        allow(Bugsnag).to receive(:notify).twice

        described_class.perform_now(appointment)

        expect(Bugsnag).to have_received(:notify).twice
      end
    end
  end

  context 'when the appointment is not pushable' do
    it 'does not delegate to the casebook pusher' do
      appointment = double(:appointment, push_to_casebook?: false)

      described_class.perform_now(appointment)

      expect(Casebook::Push).not_to receive(:new)
    end
  end
end
