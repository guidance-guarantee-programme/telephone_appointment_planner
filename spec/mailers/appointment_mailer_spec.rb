require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe AppointmentMailer, type: :mailer do
  let(:appointment) do
    build_stubbed(
      :appointment,
      email: 'test@example.org',
      start_at: DateTime.new(2016, 10, 23).in_time_zone,
      memorable_word: 'mailertest',
      accessibility_requirements: true,
      third_party_booking: true,
      dc_pot_confirmed: false
    )
  end

  before { ENV['ONLINE_CANCELLATION_URL'] = 'https://bleh.com' }
  after { ENV['ONLINE_CANCELLATION_URL'] = nil }

  describe 'Potential duplicates notification' do
    let(:appointment) { build_stubbed(:appointment) }

    subject(:mail) { described_class.potential_duplicates(appointment) }

    it 'determines the correct subject' do
      expect(subject.subject).to eq('Pension Wise Potential Duplicates')
    end

    it 'is delivered to the ops supervisor mailbox' do
      expect(subject.to).to eq(['supervisors@maps.org.uk'])
    end

    it 'contains the duplicates details' do
      expect(subject.body.encoded).to include('identified as a potential duplicate')
    end
  end

  describe 'Due diligence appointment confirmation' do
    let(:appointment) { build_stubbed(:appointment, :due_diligence) }

    subject(:mail) { described_class.confirmation(appointment) }

    it 'determines the correct subject' do
      expect(subject.subject).to eq('Pension Safeguarding Guidance Appointment')
    end

    it 'is delivered from the correct sender' do
      expect(subject['From'].unparsed_value).to eq('Pension Safeguarding Guidance Bookings <psg@moneyhelper.org.uk>')
    end

    it 'contains the due diligence specifics' do
      expect(subject.body.encoded).to include('type and name of the pension scheme you want to transfer')
    end

    it 'has the correct help number' do
      expect(subject.body.encoded).to include('0800 015 4906')
    end

    it 'has the correct heading logo' do
      expect(subject.body.encoded).to include('mhp.jpg')
    end

    it 'does not include the Pension Wise mailing address' do
      expect(subject.body.encoded).not_to include('P.O. Box 10404')
    end

    it 'does not include the cancellation link' do
      expect(subject.body.encoded).not_to include('bleh.com')
    end
  end

  describe 'BSL customer exit poll' do
    let(:mailgun_headers) { JSON.parse(mail['X-Mailgun-Variables'].value) }
    let(:appointment) { build_stubbed(:appointment, bsl_video: true) }

    subject(:mail) { described_class.bsl_customer_exit_poll(appointment) }

    it 'sends to the customer email' do
      expect(mail.to).to eq(['someone@example.com'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include('message_type' => 'bsl_exit_poll', 'appointment_id' => appointment.id)
    end

    it 'renders the exit poll vanity URL' do
      expect(subject.body.encoded).to match('https://www.pensionwise.gov.uk/bsl-exit-poll')
    end
  end

  describe 'Guider summary document missing' do
    let(:mailgun_headers) { JSON.parse(subject['X-Mailgun-Variables'].value) }
    let(:appointment) { build_stubbed(:appointment) }
    let(:body) { subject.body.encoded }

    subject { described_class.guider_summary_document_missing(appointment) }

    it 'renders the headers' do
      expect(subject.to).to eq(['some-name@example.org'])
      expect(subject.subject).to eq('Pension Wise No Summary Document Generated')
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'guider_summary_document_missing',
        'appointment_id' => appointment.id
      )
    end

    it 'includes the body specifics' do
      expect(body).to match(/A summary document has not been generated/)
    end
  end

  describe 'Guider status reminder' do
    let(:mailgun_headers) { JSON.parse(subject['X-Mailgun-Variables'].value) }
    let(:appointment) { build_stubbed(:appointment) }
    let(:body) { subject.body.encoded }

    subject { described_class.guider_status_reminder(appointment) }

    it 'renders the headers' do
      expect(subject.to).to eq(['some-name@example.org'])
      expect(subject.subject).to eq('Pension Wise Appointment status not updated')
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'guider_status_reminder',
        'appointment_id' => appointment.id
      )
    end

    it 'includes the body specifics' do
      expect(body).to match(/The status for this appointment has not been updated/)
    end
  end

  describe 'Resource Manager SMS Failure' do
    let(:mailgun_headers) { JSON.parse(subject['X-Mailgun-Variables'].value) }
    let(:appointment) { build_stubbed(:appointment) }
    let(:body) { subject.body.encoded }

    subject { described_class.resource_manager_sms_failure(appointment, 'dave@example.com') }

    it 'renders the headers' do
      expect(subject.to).to eq(['dave@example.com'])
      expect(subject.subject).to eq('Pension Wise SMS Failure')
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'resource_manager_sms_failure',
        'appointment_id' => appointment.id
      )
    end

    it 'includes the body specifics' do
      expect(body).to include(appointment.canonical_sms_number)
      expect(body).to match(%q(http://localhost:3001/appointments/\d+/edit))
    end
  end

  describe 'Resource Manager Email Failure' do
    let(:mailgun_headers) { JSON.parse(subject['X-Mailgun-Variables'].value) }
    let(:appointment) { build_stubbed(:appointment) }
    let(:body) { subject.body.encoded }

    subject { described_class.resource_manager_email_dropped(appointment, 'dave@example.com') }

    it 'renders the headers' do
      expect(subject.to).to eq(['dave@example.com'])
      expect(subject.subject).to eq('Pension Wise Email Failure')
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'resource_manager_email_dropped',
        'appointment_id' => appointment.id
      )
    end

    it 'includes the body specifics' do
      expect(body).to include(appointment.email)
      expect(body).to match(%q(http://localhost:3001/appointments/\d+/edit))
    end
  end

  describe 'Resource Manager Appointment Changed' do
    let(:resource_manager) { 'supervisors@maps.org.uk' }
    let(:appointment) { create(:appointment) }

    before { appointment.update_attribute(:first_name, 'George') }

    subject(:mail) { described_class.resource_manager_appointment_changed(appointment, resource_manager) }

    it 'renders the body specifics' do
      expect(subject.body.encoded).to match(%q(http://localhost:3001/appointments/\d+/edit))
    end

    it 'renders the names of changed attributes' do
      expect(subject.body.encoded).to match('First name')
    end
  end

  describe 'Resource Manager Appointment Rescheduled' do
    subject(:mail) { described_class.resource_manager_appointment_rescheduled(appointment, resource_manager) }

    let(:mailgun_headers) { JSON.parse(mail['X-Mailgun-Variables'].value) }
    let(:resource_manager) { 'supervisors@maps.org.uk' }

    it 'renders the headers' do
      expect(mail.subject).to eq('Pension Wise Appointment Rescheduled')
      expect(mail.to).to eq(['supervisors@maps.org.uk'])
      expect(mail.from).to eq(['booking.pensionwise@moneyhelper.org.uk'])
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

  describe 'Resource Manager Appointment Rescheduled Away' do
    subject(:mail) { described_class.resource_manager_appointment_rescheduled_away(appointment, resource_manager) }

    let(:mailgun_headers) { JSON.parse(mail['X-Mailgun-Variables'].value) }
    let(:resource_manager) { 'supervisors@maps.org.uk' }

    before { appointment.previous_guider = create(:guider, :waltham_forest) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Pension Wise Appointment Rescheduled Away')
      expect(mail.to).to eq(['supervisors@maps.org.uk'])
      expect(mail.from).to eq(['booking.pensionwise@moneyhelper.org.uk'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'resource_manager_appointment_rescheduled_away',
        'appointment_id' => appointment.id
      )
    end

    it 'renders the body specifics' do
      expect(subject.body.encoded).to include(appointment.previous_guider.name)
    end
  end

  describe 'Resource Manager Appointment Cancelled' do
    subject(:mail) { described_class.resource_manager_appointment_cancelled(appointment, resource_manager) }

    let(:mailgun_headers) { JSON.parse(mail['X-Mailgun-Variables'].value) }
    let(:resource_manager) { 'supervisors@maps.org.uk' }

    it 'renders the headers' do
      expect(mail.subject).to eq('Pension Wise Appointment Cancelled')
      expect(mail.to).to eq(['supervisors@maps.org.uk'])
      expect(mail.from).to eq(['booking.pensionwise@moneyhelper.org.uk'])
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
      expect(mail.from).to eq(['booking.pensionwise@moneyhelper.org.uk'])
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

  describe 'Adjustment' do
    subject(:mail) { described_class.adjustment(appointment, resource_manager) }

    let(:mailgun_headers) { JSON.parse(mail['X-Mailgun-Variables'].value) }
    let(:resource_manager) { 'supervisors@maps.org.uk' }

    it 'renders the headers' do
      expect(mail.subject).to eq('Pension Wise Appointment Adjustment')
      expect(mail.to).to eq(['supervisors@maps.org.uk'])
      expect(mail.from).to eq(['booking.pensionwise@moneyhelper.org.uk'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'adjustment',
        'appointment_id' => appointment.id
      )
    end

    it 'renders the body specifics' do
      expect(subject.body.encoded).to match(%q(http://localhost:3001/appointments/\d+/edit))
      # include the accessibility adjustment
      expect(subject.body.encoded).to include('they require help')
      # include the third party booking disclaimer
      expect(subject.body.encoded).to include('appointment on behalf')
      # include the DC unsure disclaimer
      expect(subject.body.encoded).to include('unsure if they have a DC')
    end

    context 'when `Appointment#adjustments?` is false' do
      it 'does nothing' do
        allow(appointment).to receive(:adjustments?).and_return(false)

        expect(mail.message).to be_an(ActionMailer::Base::NullMail)
      end
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
      expect(mail.subject).to eq('Pension Wise Appointment')
      expect(mail.to).to eq([appointment.email])
      expect(mail.from).to eq(['booking.pensionwise@moneyhelper.org.uk'])
      expect(mail['From'].unparsed_value).to include('Pension Wise')
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
        expect(body).to include('around 60 minutes')
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
        expect(body).to include('will call you on')
      end

      it 'includes the correct PW heading logo' do
        expect(body).to include('pw.jpg')
      end

      it 'includes the cancellation link' do
        expect(body).to include('bleh.com')
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
      expect(mail.subject).to eq('Pension Wise Appointment')
      expect(mail.to).to eq([appointment.email])
      expect(mail.from).to eq(['booking.pensionwise@moneyhelper.org.uk'])
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
        expect(body).to include('around 60 minutes')
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

      it 'includes the cancellation link' do
        expect(body).to include('bleh.com')
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
      expect(mail.subject).to eq('Pension Wise Appointment')
      expect(mail.to).to eq([appointment.email])
      expect(mail.from).to eq(['booking.pensionwise@moneyhelper.org.uk'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'booking_reminder',
        'appointment_id' => appointment.id
      )
    end

    describe 'rendering the body' do
      let(:body) { subject.html_part.body.decoded.to_s }

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
        expect(body).to include('One of our pension specialists will call')
      end

      it 'includes the date' do
        expect(body).to include('23 October 2016')
      end

      it 'includes the time' do
        expect(body).to include('12:00am')
      end

      it 'includes the duration' do
        expect(body).to include('around 60 minutes')
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

      it 'includes the full MoneyHelper blurb' do
        expect(body).to include('MoneyHelper collects and stores')
      end

      it 'includes the cancellation link' do
        expect(body).to include('bleh.com')
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
      expect(mail.subject).to eq('Pension Wise Appointment')
      expect(mail.to).to eq([appointment.email])
      expect(mail.from).to eq(['booking.pensionwise@moneyhelper.org.uk'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'booking_cancelled',
        'appointment_id' => appointment.id
      )
    end

    describe 'rendering the body' do
      let(:body) { subject.body.encoded }

      it 'does not include the full MoneyHelper blurb' do
        expect(body).not_to include('data will be shared')
      end

      context 'when cancelled by pension wise' do
        it 'includes the correct messaging' do
          appointment.status = :cancelled_by_pension_wise

          expect(body).to include('we need to cancel your')
          expect(body).to include('arrange a new date')
        end
      end

      context 'when cancelled otherwise' do
        it 'includes information' do
          expect(body).to include('Your Pension Wise appointment has been cancelled')
          expect(body).to include(appointment.id.to_s)
        end
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
      expect(mail.subject).to eq('Pension Wise Appointment')
      expect(mail.to).to eq([appointment.email])
      expect(mail.from).to eq(['booking.pensionwise@moneyhelper.org.uk'])
    end

    it 'renders the mailgun specific headers' do
      expect(mailgun_headers).to include(
        'message_type'   => 'booking_missed',
        'appointment_id' => appointment.id
      )
    end

    describe 'rendering the body' do
      let(:body) { subject.html_part.body.decoded.to_s }

      it 'includes information' do
        expect(body).to include('unable to contact you')
      end

      it 'includes the date' do
        expect(body).to include('23 October 2016')
      end

      it 'includes the time' do
        expect(body).to include('12:00am')
      end

      it 'includes the reference number' do
        expect(body).to include(appointment.id.to_s)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
