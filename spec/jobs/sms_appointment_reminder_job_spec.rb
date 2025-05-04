require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe SmsAppointmentReminderJob, '#perform' do
  let(:client) { double(Notifications::Client, send_sms: true) }

  context 'for Due Diligence' do
    let(:appointment) { create(:appointment, :due_diligence, created_at: 1.day.ago) }

    before do
      ENV['DUE_DILIGENCE_NOTIFY_API_KEY'] = 'blahblah'

      allow(Notifications::Client).to receive(:new).and_return(client)
    end

    after do
      ENV.delete('DUE_DILIGENCE_NOTIFY_API_KEY')
    end

    it 'sends an SMS with the DD template' do
      travel_to(Time.zone.parse('2018-07-03 12:00')) do
        expect(client).to receive(:send_sms).with(
          phone_number: '07715 930 444',
          template_id: SmsAppointmentReminderJob::DUE_DILIGENCE_TEMPLATE_ID,
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

  context 'for Pension Wise' do
    let(:appointment) { create(:appointment, created_at: 1.day.ago) }

    context 'when Notify cannot send the SMS to the given number' do
      it 'creates an SMS failure activity and notifies resource managers' do
        allow(SmsFailureNotificationsJob).to receive(:perform_later)
        allow(client).to receive(:send_sms)
          .and_raise(Notifications::Client::BadRequestError.new(double(code: 400, body: 'meh')))

        described_class.perform_now(appointment)

        expect(appointment.activities.find_by(type: 'SmsFailureActivity')).to be
        expect(appointment.activities.find_by(type: 'SmsReminderActivity')).to be_nil

        expect(SmsFailureNotificationsJob).to have_received(:perform_later)
      end
    end

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
      ENV['PENSION_WISE_NOTIFY_API_KEY'] = 'blahblah'

      allow(Notifications::Client).to receive(:new).and_return(client)
    end

    after do
      ENV.delete('PENSION_WISE_NOTIFY_API_KEY')
    end
  end
end
# rubocop:enable Metrics/BlockLength
