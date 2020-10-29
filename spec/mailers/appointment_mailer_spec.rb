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

  describe 'Resource Manager Appointment Rescheduled' do
    subject(:mail) { described_class.resource_manager_appointment_rescheduled(appointment, resource_manager) }

    let(:mailgun_headers) { JSON.parse(mail['X-Mailgun-Variables'].value) }
    let(:resource_manager) { 'supervisors@maps.org.uk' }

    it 'renders the headers' do
      expect(mail.subject).to eq('Pension Wise Appointment Rescheduled')
      expect(mail.to).to eq(['supervisors@maps.org.uk'])
      expect(mail.from).to eq(['booking@pensionwise.gov.uk'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'resource_manager_appointment_rescheduled',
        'appointment_id' => appointment.id
      )
    end

    it 'renders the body specifics' do
      expect(subject.body.encoded).to match(%q(http://localhost:3001/appointments/\d+/edit))
      expect(subject.body.encoded).to include(appointment.guider.name)
    end
  end

  describe 'Resource Manager Appointment Cancelled' do
    subject(:mail) { described_class.resource_manager_appointment_cancelled(appointment, resource_manager) }

    let(:mailgun_headers) { JSON.parse(mail['X-Mailgun-Variables'].value) }
    let(:resource_manager) { 'supervisors@maps.org.uk' }

    it 'renders the headers' do
      expect(mail.subject).to eq('Pension Wise Appointment Cancelled')
      expect(mail.to).to eq(['supervisors@maps.org.uk'])
      expect(mail.from).to eq(['booking@pensionwise.gov.uk'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'resource_manager_appointment_cancelled',
        'appointment_id' => appointment.id
      )
    end

    it 'renders the body specifics' do
      expect(subject.body.encoded).to match(%q(http://localhost:3001/appointments/\d+/edit))
      expect(subject.body.encoded).to include(appointment.guider.name)
    end
  end

  describe 'Resource Manager Appointment Created' do
    subject(:mail) { described_class.resource_manager_appointment_created(appointment, resource_manager) }

    let(:mailgun_headers) { JSON.parse(mail['X-Mailgun-Variables'].value) }
    let(:resource_manager) { 'supervisors@maps.org.uk' }

    it 'renders the headers' do
      expect(mail.subject).to eq('Pension Wise Appointment Created')
      expect(mail.to).to eq(['supervisors@maps.org.uk'])
      expect(mail.from).to eq(['booking@pensionwise.gov.uk'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'resource_manager_appointment_created',
        'appointment_id' => appointment.id
      )
    end

    it 'renders the body specifics' do
      expect(subject.body.encoded).to match(%q(http://localhost:3001/appointments/\d+/edit))
      expect(subject.body.encoded).to include(appointment.guider.name)
    end
  end

  describe 'Accessibility Adjustment' do
    subject(:mail) { described_class.accessibility_adjustment(appointment, resource_manager) }

    let(:mailgun_headers) { JSON.parse(mail['X-Mailgun-Variables'].value) }
    let(:resource_manager) { 'supervisors@maps.org.uk' }

    it 'renders the headers' do
      expect(mail.subject).to eq('Pension Wise Accessibility Adjustment')
      expect(mail.to).to eq(['supervisors@maps.org.uk'])
      expect(mail.from).to eq(['booking@pensionwise.gov.uk'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'accessibility_adjustment',
        'appointment_id' => appointment.id
      )
    end

    it 'renders the body specifics' do
      expect(subject.body.encoded).to match(%q(http://localhost:3001/appointments/\d+/edit))
    end
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

      context 'when the appointment is BSL video based' do
        it 'includes the video appointment specifics' do
          appointment.bsl_video = true

          expect(body).to include('British Sign Language')
        end
      end

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

      it 'includes the phone specifics' do
        expect(body).to include('call you on the number')
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

      context 'when the appointment is BSL video based' do
        before do
          appointment.bsl_video = true
        end

        it 'includes the video appointment specifics' do
          expect(body).to include('British Sign Language')
        end

        it 'does not include the customer phone number' do
          expect(body).not_to include(appointment.phone)
        end
      end

      it 'includes the phone specifics' do
        expect(body).to include('call you on the number')
      end

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
