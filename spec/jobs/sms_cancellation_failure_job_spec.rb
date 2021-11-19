require 'rails_helper'

RSpec.describe SmsCancellationFailureJob, '#perform' do
  let(:number) { '07715 930 455' }
  let(:client) { double(Notifications::Client, send_sms: true) }

  context 'for Pension Wise appointments' do
    it 'sends an SMS' do
      expect(client).to receive(:send_sms).with(
        phone_number: '07715 930 455',
        template_id: SmsCancellationFailureJob::TEMPLATES['pension_wise'],
        reference: '07715 930 455'
      )

      described_class.new.perform(number, 'pension_wise')
    end

    before do
      ENV['PENSION_WISE_NOTIFY_API_KEY'] = 'blahblah'

      allow(Notifications::Client).to receive(:new).with('blahblah').and_return(client)
    end

    after do
      ENV.delete('PENSION_WISE_NOTIFY_API_KEY')
    end
  end

  context 'for Due Diligence appointments' do
    it 'sends an SMS' do
      expect(client).to receive(:send_sms).with(
        phone_number: '07715 930 455',
        template_id: SmsCancellationFailureJob::TEMPLATES['due_diligence'],
        reference: '07715 930 455'
      )

      described_class.new.perform(number, 'due_diligence')
    end

    before do
      ENV['DUE_DILIGENCE_NOTIFY_API_KEY'] = 'blahblah'

      allow(Notifications::Client).to receive(:new).with('blahblah').and_return(client)
    end

    after do
      ENV.delete('DUE_DILIGENCE_NOTIFY_API_KEY')
    end
  end
end
