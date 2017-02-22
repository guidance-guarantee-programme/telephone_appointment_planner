require 'rails_helper'

RSpec.describe AppointmentMailer, type: :mailer do
  let(:appointment) do
    build_stubbed(
      :appointment,
      email: 'test@example.org',
      start_at: DateTime.new(2016, 10, 23).in_time_zone,
      memorable_word: 'mailertest'
    )
  end

  describe 'Confirmation' do
    subject(:mail) { described_class.confirmation(appointment) }
    let(:mailgun_headers) { JSON.parse(mail['X-Mailgun-Variables'].value) }

    it 'guards against the absence of a recipient' do
      appointment.email = ''

      expect(mail.message).to be_an(ActionMailer::Base::NullMail)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('Your Pension Wise Appointment')
      expect(mail.to).to eq([appointment.email])
      expect(mail.from).to eq(['booking@pensionwise.gov.uk'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'booking_created',
        'appointment_id' => appointment.id
      )
    end

    describe 'rendering the body' do
      let(:body) { subject.body.encoded }

      it 'includes the date' do
        expect(body).to include('23 October 2016')
      end

      it 'includes the time' do
        expect(body).to include('12:00am')
      end

      it 'includes the duration' do
        expect(body).to include('45 to 60 minutes')
      end

      it 'includes the contact number' do
        expect(body).to include(appointment.phone)
      end

      it 'includes the memorable word' do
        expect(body).to include('m********t')
      end

      it 'includes the reference number' do
        expect(body).to include(appointment.id.to_s)
      end
    end
  end

  describe 'Updated' do
    subject(:mail) { described_class.updated(appointment) }
    let(:mailgun_headers) { JSON.parse(mail['X-Mailgun-Variables'].value) }

    it 'guards against the absence of a recipient' do
      appointment.email = ''

      expect(mail.message).to be_an(ActionMailer::Base::NullMail)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('Your Pension Wise Appointment')
      expect(mail.to).to eq([appointment.email])
      expect(mail.from).to eq(['booking@pensionwise.gov.uk'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'booking_updated',
        'appointment_id' => appointment.id
      )
    end

    describe 'rendering the body' do
      let(:body) { subject.body.encoded }

      it 'includes the date' do
        expect(body).to include('23 October 2016')
      end

      it 'includes the time' do
        expect(body).to include('12:00am')
      end

      it 'includes the duration' do
        expect(body).to include('45 to 60 minutes')
      end

      it 'includes the contact number' do
        expect(body).to include(appointment.phone)
      end

      it 'includes the memorable word' do
        expect(body).to include('m********t')
      end

      it 'includes the reference number' do
        expect(body).to include(appointment.id.to_s)
      end
    end
  end

  describe 'Reminder' do
    subject(:mail) { described_class.reminder(appointment) }
    let(:mailgun_headers) { JSON.parse(mail['X-Mailgun-Variables'].value) }

    it 'guards against the absence of a recipient' do
      appointment.email = ''

      expect(mail.message).to be_an(ActionMailer::Base::NullMail)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('Your Pension Wise Appointment')
      expect(mail.to).to eq([appointment.email])
      expect(mail.from).to eq(['booking@pensionwise.gov.uk'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'booking_reminder',
        'appointment_id' => appointment.id
      )
    end

    describe 'rendering the body' do
      let(:body) { subject.body.encoded }

      it 'includes the date' do
        expect(body).to include('23 October 2016')
      end

      it 'includes the time' do
        expect(body).to include('12:00am')
      end

      it 'includes the duration' do
        expect(body).to include('45 to 60 minutes')
      end

      it 'includes the contact number' do
        expect(body).to include(appointment.phone)
      end

      it 'includes the memorable word' do
        expect(body).to include('m********t')
      end

      it 'includes the reference number' do
        expect(body).to include(appointment.id.to_s)
      end
    end
  end

  describe 'Cancelled' do
    subject(:mail) { described_class.cancelled(appointment) }
    let(:mailgun_headers) { JSON.parse(mail['X-Mailgun-Variables'].value) }

    it 'guards against the absence of a recipient' do
      appointment.email = ''

      expect(mail.message).to be_an(ActionMailer::Base::NullMail)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('Your Pension Wise Appointment')
      expect(mail.to).to eq([appointment.email])
      expect(mail.from).to eq(['booking@pensionwise.gov.uk'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'booking_cancelled',
        'appointment_id' => appointment.id
      )
    end

    describe 'rendering the body' do
      let(:body) { subject.body.encoded }

      it 'includes information' do
        expect(body).to include('We=E2=80=99ve cancelled your appointment')
        expect(body).to include(appointment.id.to_s)
      end
    end
  end

  describe 'Missed' do
    subject(:mail) { described_class.missed(appointment) }
    let(:mailgun_headers) { JSON.parse(mail['X-Mailgun-Variables'].value) }

    it 'guards against the absence of a recipient' do
      appointment.email = ''

      expect(mail.message).to be_an(ActionMailer::Base::NullMail)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('Your Pension Wise Appointment')
      expect(mail.to).to eq([appointment.email])
      expect(mail.from).to eq(['booking@pensionwise.gov.uk'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'booking_missed',
        'appointment_id' => appointment.id
      )
    end

    describe 'rendering the body' do
      let(:body) { subject.body.encoded }

      it 'includes information' do
        expect(body).to include('Our records show that your Pension Wise telephone appointment was missed')
      end

      it 'includes the date' do
        expect(body).to include('23 October 2016')
      end

      it 'includes the time' do
        expect(body).to include('12:00am')
      end

      it 'includes the contact number' do
        expect(body).to include(appointment.phone)
      end

      it 'includes the reference number' do
        expect(body).to include(appointment.id.to_s)
      end
    end
  end
end
