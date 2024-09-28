require 'rails_helper'

RSpec.describe SmsAppointmentConfirmationJob, '#perform' do
  let(:client) { double(Notifications::Client, send_sms: true) }
  let(:appointment) { create(:appointment, created_at: 1.day.ago) }

  before do
    ENV['PENSION_WISE_NOTIFY_API_KEY'] = 'blahblah'

    allow(Notifications::Client).to receive(:new).and_return(client)
  end

  after do
    ENV.delete('PENSION_WISE_NOTIFY_API_KEY')
  end

  it 'sends an SMS with the standard template' do
    travel_to(Time.zone.parse('2022-04-27 12:00')) do
      expect(client).to receive(:send_sms).with(
        phone_number: '07715 930 444',
        template_id: described_class::TEMPLATE_ID,
        reference: appointment.to_param,
        personalisation: {
          date: a_string_matching(/12:00pm, .*/),
          reference: appointment.to_param
        }
      )

      described_class.new.perform(appointment)

      expect(appointment.activities.find_by(type: 'SmsConfirmationActivity')).to be
    end
  end
end
