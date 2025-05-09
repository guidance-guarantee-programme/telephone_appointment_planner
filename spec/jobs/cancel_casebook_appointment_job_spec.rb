require 'rails_helper'

RSpec.describe CancelCasebookAppointmentJob, '#perform' do
  context 'when the appointment is cancellable' do
    let(:appointment) { double(:appointment, cancelled?: true, casebook_appointment_id?: true) }
    let(:casebook_cancel) { instance_double(Casebook::Cancel) }

    before do
      allow(Casebook::Cancel).to receive(:new).with(appointment).and_return(casebook_cancel)
    end

    it 'delegates to the casebook canceller' do
      allow(casebook_cancel).to receive(:call)

      described_class.perform_now(appointment)

      expect(casebook_cancel).to have_received(:call)
    end
  end
end
