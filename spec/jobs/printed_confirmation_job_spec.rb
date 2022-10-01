require 'rails_helper'

RSpec.describe PrintedConfirmationJob, '#perform' do
  let(:appointment) { build_stubbed(:appointment) }
  let(:client) { double(Notifications::Client, send_letter: true) }

  context 'when an email is present' do
    it 'does not send a letter' do
      expect(client).to_not receive(:send_letter)

      described_class.new.perform(appointment)
    end
  end

  context 'when an address is present' do
    let(:appointment) do
      create(
        :appointment,
        :with_address,
        first_name: 'Daisy',
        last_name: 'George',
        start_at: Time.zone.parse('2022-07-27 13:00')
      )
    end

    it 'sends a letter' do
      expect(client).to receive(:send_letter).with(
        template_id: PrintedConfirmationJob::TEMPLATE_ID,
        reference: appointment.to_param,
        personalisation: {
          reference: appointment.to_param,
          date: '27 July 2022',
          time: '1:00pm BST',
          phone: '0208 252 4758',
          memorable_word: 'l*****e',
          address_line_1: 'Daisy George',
          address_line_2: '10 Some Road',
          address_line_3: 'Some Street',
          address_line_4: 'Somewhere',
          address_line_5: 'Some Town',
          address_line_6: 'Some County',
          address_line_7: 'E3 3NN'
        }
      )

      described_class.new.perform(appointment)

      expect(appointment.activities.first).to be_an(PrintedConfirmationActivity)
    end

    context 'when the appointment was rescheduled' do
      it 'uses the rescheduling template ID instead' do
        appointment.rescheduled_at = Time.current

        expect(client).to receive(:send_letter).with(
          hash_including(
            template_id: PrintedConfirmationJob::RESCHEDULE_TEMPLATE_ID
          )
        )

        described_class.new.perform(appointment)
      end
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
