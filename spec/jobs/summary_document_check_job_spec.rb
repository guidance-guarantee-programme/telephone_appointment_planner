require 'rails_helper'

RSpec.describe SummaryDocumentCheckJob, '#perform' do
  context 'when the appointment was summarised already' do
    it 'does not send the notification' do
      appointment = create(:appointment, :digital_summarised)

      expect(AppointmentMailer).not_to receive(:guider_summary_document_missing).with(appointment)

      described_class.perform_now(appointment)
    end
  end

  context 'when the appointment was not summarised already' do
    it 'does not send the notification' do
      appointment = create(:appointment, status: :complete)

      mailer = double(deliver_now: true)

      expect(AppointmentMailer).to receive(:guider_summary_document_missing).with(appointment).and_return(mailer)

      described_class.perform_now(appointment)
    end
  end
end
