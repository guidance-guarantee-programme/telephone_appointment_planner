require 'rails_helper'

RSpec.describe RescheduleCasebookAppointmentJob, '#perform' do # rubocop:disable Metrics/BlockLength
  context 'when the appointment is not for a casebook-enlisted guider' do
    it 'does not attempt to cancel or push' do
      appointment = build_stubbed(:appointment)

      expect(described_class.perform_now(appointment)).to be_falsey
    end
  end

  context 'when the appointment is for a casebook-enlisted guider' do # rubocop:disable Metrics/BlockLength
    let(:reschedule) { instance_double(Casebook::Reschedule) }

    before do
      allow(Casebook::Reschedule).to receive(:new).with(appointment).and_return(reschedule)
      allow(reschedule).to receive(:call)
    end

    context 'when a casebook error occurs' do
      let(:appointment) { build_stubbed(:appointment, :casebook_guider, :casebook_pushed) }

      it 'notifies bugsnag' do
        allow(reschedule).to receive(:call).and_raise(Casebook::ApiError)
        allow(Bugsnag).to receive(:notify).twice

        described_class.perform_now(appointment)

        expect(Bugsnag).to have_received(:notify).twice
      end
    end

    context 'and the appointment was already pushed to casebook' do
      let(:appointment) { build_stubbed(:appointment, :casebook_guider, :casebook_pushed) }

      it 'reschedules casebook appointment' do
        described_class.perform_now(appointment)

        expect(reschedule).to have_received(:call)
      end
    end

    context 'and the appointment was not yet pushed to casebook' do
      context 'and the appointment has already been processed manually' do
        it 'does what exactly?'
      end
    end
  end
end
