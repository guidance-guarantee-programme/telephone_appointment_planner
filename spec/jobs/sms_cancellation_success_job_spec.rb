require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe SmsCancellationSuccessJob, '#perform' do
  let(:client) { double(Notifications::Client, send_sms: true) }

  context 'for Due Diligence' do
    let(:appointment) { create(:appointment, :due_diligence, start_at: Time.zone.parse('2019-01-01 13:00 UTC')) }

    before do
      ENV['DUE_DILIGENCE_NOTIFY_API_KEY'] = 'blahblah'

      allow(Notifications::Client).to receive(:new).and_return(client)
    end

    after do
      ENV.delete('DUE_DILIGENCE_NOTIFY_API_KEY')
    end

    it 'sends an SMS with the appropriate template' do
      expect(client).to receive(:send_sms).with(
        phone_number: '07715 930 444',
        template_id: SmsCancellationSuccessJob::DUE_DILIGENCE_TEMPLATE_ID,
        reference: appointment.to_param,
        personalisation: {
          date: '1:00pm, 1 Jan 2019 (GMT)',
          reference: appointment.to_param
        }
      )

      described_class.new.perform(appointment)
    end
  end

  context 'for Pension Wise' do
    let(:appointment) { create(:appointment, start_at: Time.zone.parse('2019-01-01 13:00 UTC')) }

    context 'for a standard appointment' do
      it 'sends an SMS with the appropriate template' do
        expect(client).to receive(:send_sms).with(
          phone_number: '07715 930 444',
          template_id: SmsCancellationSuccessJob::STANDARD_TEMPLATE_ID,
          reference: appointment.to_param,
          personalisation: {
            date: '1:00pm, 1 Jan 2019 (GMT)',
            reference: appointment.to_param
          }
        )

        described_class.new.perform(appointment)
      end
    end

    context 'for a BSL appointment' do
      it 'sends an SMS with the appropriate template' do
        appointment.bsl_video = true

        expect(client).to receive(:send_sms).with(
          phone_number: '07715 930 444',
          template_id: SmsCancellationSuccessJob::BSL_TEMPLATE_ID,
          reference: appointment.to_param,
          personalisation: {
            date: '1:00pm, 1 Jan 2019 (GMT)',
            reference: appointment.to_param
          }
        )

        described_class.new.perform(appointment)
      end
    end

    before do
      ENV['PENSION_WISE_NOTIFY_API_KEY'] = 'blahblah'

      allow(Notifications::Client).to receive(:new).and_return(client)
    end

    after do
      ENV.delete('PENSION_WISE_NOTIFY_API_KEY')
    end
  end
end
# rubocop:enable Metrics/BlockLength
