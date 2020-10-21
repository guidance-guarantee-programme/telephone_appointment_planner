require 'rails_helper'

RSpec.describe SmsAppointmentReminderJob, '#perform' do
  let(:appointment) { create(:appointment, created_at: 1.day.ago) }
  let(:client) { double(Notifications::Client, send_sms: true) }

  context 'for non-BSL appointments' do
    it 'sends an SMS with the standard template' do
      travel_to(Time.zone.parse('2018-07-03 12:00')) do
        expect(client).to receive(:send_sms).with(
          phone_number: '07715 930 444',
          template_id: SmsAppointmentReminderJob::STANDARD_TEMPLATE_ID,
          reference: appointment.to_param,
          personalisation: {
            date: a_string_matching(/12:00pm, .*/)
          }
        )

        described_class.new.perform(appointment)

        expect(appointment.activities.find_by(type: 'SmsReminderActivity')).to be
      end
    end
  end

  context 'for BSL video appointments' do
    it 'sends an SMS with the BSL template' do
      appointment.bsl_video = true

      travel_to(Time.zone.parse('2018-07-03 12:00')) do
        expect(client).to receive(:send_sms).with(
          phone_number: '07715 930 444',
          template_id: SmsAppointmentReminderJob::BSL_TEMPLATE_ID,
          reference: appointment.to_param,
          personalisation: {
            date: a_string_matching(/12:00pm, .*/)
          }
        )

        described_class.new.perform(appointment)

        expect(appointment.activities.find_by(type: 'SmsReminderActivity')).to be
      end
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
