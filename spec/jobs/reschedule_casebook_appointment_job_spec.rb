require 'rails_helper'

RSpec.describe RescheduleCasebookAppointmentJob, '#perform' do
  context 'when the appointment is not for a casebook-enlisted guider' do
    it 'does not attempt to cancel or push' do
      appointment = build_stubbed(:appointment)

      expect(described_class.perform_now(appointment)).to be_falsey
    end
  end

  context 'when the appointment is for a casebook-enlisted guider' do
    let(:reschedule) { instance_double(Casebook::Reschedule) }

    before do
      allow(Casebook::Reschedule).to receive(:new).with(appointment).and_return(reschedule)
      allow(reschedule).to receive(:call)
    end

    context 'and the appointment was already pushed to casebook' do
      let(:appointment) { build_stubbed(:appointment, :casebook_guider, :casebook_pushed) }

      it 'reschedules casebook appointment' do
        described_class.perform_now(appointment)

        expect(reschedule).to have_received(:call)
      end
    end
  end
end
