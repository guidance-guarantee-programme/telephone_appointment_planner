require 'rails_helper'

RSpec.describe SmsAppointmentReminderJob, '#perform' do
  let(:appointment) { create(:appointment, created_at: 1.day.ago) }
  let(:client) { double(Notifications::Client, send_sms: true) }

  it 'sends an SMS' do
    expect(client).to receive(:send_sms).with(
      phone_number: '07715 930 444',
      template_id: SmsAppointmentReminderJob::TEMPLATE_ID,
      reference: appointment.to_param,
      personalisation: {
        date: a_string_matching(/12:00pm/)
      }
    )

    described_class.new.perform(appointment)

    expect(appointment.activities.first).to be_an(SmsReminderActivity)
  end

  before do
    ENV['NOTIFY_API_KEY'] = 'blahblah'

    allow(Notifications::Client).to receive(:new).and_return(client)
  end

  after do
    ENV.delete('NOTIFY_API_KEY')
  end
end
