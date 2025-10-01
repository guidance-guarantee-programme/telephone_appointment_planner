require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe RescheduleCasebookAppointmentJob, '#perform' do
  context 'when the appointment is not for a casebook-enlisted guider' do
    context 'when the appointment was not previously for a casebook-enlisted guider' do
      it 'does not attempt to cancel or push' do
        appointment = build_stubbed(:appointment)

        expect(described_class.perform_now(appointment)).to be_falsey
      end
    end

    context 'when the appointment was previously for a casebook-enlisted guider' do
      let(:cancel) { instance_double(Casebook::Cancel) }
      let(:appointment) { build_stubbed(:appointment, :casebook_pushed) }

      before do
        allow(Casebook::Cancel).to receive(:new).with(appointment).and_return(cancel)
        allow(cancel).to receive(:call)
      end

      it 'cancels the existing casebook appointment' do
        described_class.perform_now(appointment)

        expect(cancel).to have_received(:call)
      end
    end
  end

  context 'when the appointment is for a casebook-enlisted guider' do
    let(:reschedule) { instance_double(Casebook::Reschedule) }
    let(:cancel) { instance_double(Casebook::Cancel) }
    let(:push) { instance_double(Casebook::Push) }

    before do
      allow(Casebook::Reschedule).to receive(:new).with(appointment).and_return(reschedule)
      allow(reschedule).to receive(:call)

      allow(Casebook::Push).to receive(:new).with(appointment).and_return(push)
      allow(push).to receive(:call)

      allow(Casebook::Cancel).to receive(:new).with(appointment).and_return(cancel)
      allow(cancel).to receive(:call)
    end

    context 'when the appointment was not yet pushed to casebook' do
      let(:appointment) { build_stubbed(:appointment, :casebook_guider) }

      it 'creates the appointment with casebook' do
        described_class.perform_now(appointment)

        expect(push).to have_received(:call)
      end
    end

    context 'and the appointment was already pushed to casebook' do
      let(:appointment) { build_stubbed(:appointment, :casebook_guider, :casebook_pushed) }

      it 'cancels and reschedules casebook appointment' do
        described_class.perform_now(appointment)

        expect(cancel).to have_received(:call)
        expect(reschedule).to have_received(:call)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
