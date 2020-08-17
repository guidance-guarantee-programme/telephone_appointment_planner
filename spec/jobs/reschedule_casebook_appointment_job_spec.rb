require 'rails_helper'

RSpec.describe RescheduleCasebookAppointmentJob, '#perform' do
  context 'when the appointment is not for a casebook-enlisted guider' do
    it 'does not attempt to cancel or push' do
      appointment = build_stubbed(:appointment)

      expect(described_class.perform_now(appointment)).to be_falsey
    end
  end

  context 'when the appointment is for a casebook-enlisted guider' do
    let(:push) { instance_double(Casebook::Push) }
    let(:cancel) { instance_double(Casebook::Cancel) }

    before do
      allow(Casebook::Push).to receive(:new).with(appointment).and_return(push)
      allow(Casebook::Cancel).to receive(:new).with(appointment).and_return(cancel)

      allow(cancel).to receive(:call)
      allow(push).to receive(:call)
    end

    context 'when a casebook error occurs' do
      let(:appointment) { build_stubbed(:appointment, :casebook_guider, :casebook_pushed) }

      it 'notifies bugsnag' do
        allow(cancel).to receive(:call).and_raise(Casebook::ApiError)
        allow(Bugsnag).to receive(:notify).with(instance_of(Casebook::ApiError))

        described_class.perform_now(appointment)

        expect(Bugsnag).to have_received(:notify)
      end
    end

    context 'and the appointment was already pushed to casebook' do
      let(:appointment) { build_stubbed(:appointment, :casebook_guider, :casebook_pushed) }

      it 'cancels the existing casebook appointment and pushes' do
        described_class.perform_now(appointment)

        expect(cancel).to have_received(:call)
        expect(push).to have_received(:call)
      end
    end

    context 'and the appointment was not yet pushed to casebook' do
      context 'and the appointment has already been processed manually' do
        it 'does what exactly?'
      end

      context 'and the appointment has not yet been processed manually' do
        let(:appointment) { build_stubbed(:appointment, :casebook_guider) }

        it 'does not attempt to cancel the existing casebook appointment but pushes' do
          described_class.perform_now(appointment)

          expect(cancel).to_not have_received(:call)
          expect(push).to have_received(:call)
        end
      end
    end
  end
end
