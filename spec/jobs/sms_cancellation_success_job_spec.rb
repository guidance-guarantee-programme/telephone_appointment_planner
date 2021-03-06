require 'rails_helper'

RSpec.describe SmsCancellationSuccessJob, '#perform' do
  let(:appointment) { create(:appointment, start_at: Time.zone.parse('2019-01-01 13:00 UTC')) }
  let(:client) { double(Notifications::Client, send_sms: true) }

  context 'for a standard appointment' do
    it 'sends an SMS with the appropriate template' do
      expect(client).to receive(:send_sms).with(
        phone_number: '07715 930 444',
        template_id: SmsCancellationSuccessJob::STANDARD_TEMPLATE_ID,
        reference: appointment.to_param,
        personalisation: {
          date: '1:00pm, 1 Jan 2019 (GMT)'
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
          date: '1:00pm, 1 Jan 2019 (GMT)'
        }
      )

      described_class.new.perform(appointment)
    end
  end

  before do
    ENV['NOTIFY_API_KEY'] = 'blahblah'

    allow(Notifications::Client).to receive(:new).and_return(client)
  end

  after do
    ENV.delete('NOTIFY_API_KEY')
  end
end
