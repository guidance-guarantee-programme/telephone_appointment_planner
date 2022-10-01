require 'rails_helper'

RSpec.describe Notifier, '#call' do
  subject { described_class.new(appointment, modifying_agent) }
  let!(:appointment) { create(:appointment) }
  let(:mailer) { double }
  let(:activity) { double(id: 1) }
  let(:modifying_agent) { nil }

  before do
    allow(AppointmentMailer).to receive(:cancelled) { mailer }
    allow(AppointmentMailer).to receive(:confirmation) { mailer }
    allow(AppointmentMailer).to receive(:missed) { mailer }
    allow(AppointmentMailer).to receive(:updated) { mailer }
    allow(mailer).to receive(:deliver)
  end

  context 'when an appointment is otherwise altered' do
    context 'when effected by a TP agent' do
      let(:modifying_agent) { create(:agent, :tp) }

      context 'when the changed attribute should notify' do
        it 'updates the resource managers' do
          appointment.update_attribute(:first_name, 'Daisy')

          expect(AgentChangedNotificationsJob).to receive(:perform_later).with(appointment)

          subject.call
        end
      end

      context 'when the changed attribute should not notify' do
        it 'does not update resource managers' do
          appointment.update_attribute(:data_subject_name, 'Smithson')

          expect(AgentChangedNotificationsJob).to_not receive(:perform_later).with(appointment)

          subject.call
        end
      end
    end

    context 'when effected by another type of user' do
      it 'does not update resource managers' do
        appointment.update_attribute(:first_name, 'Daisy')

        expect(AgentChangedNotificationsJob).to_not receive(:perform_later).with(appointment)

        subject.call
      end
    end
  end

  context 'when an appointment is updated to include an ’adjustment’' do
    context 'when the person effecting the change is a TP agent' do
      let(:modifying_agent) { create(:agent, :tp) }

      it 'enqueues the adjustment notifications job' do
        appointment.update_attribute(:accessibility_requirements, true)

        expect(AdjustmentNotificationsJob).to receive(:perform_later).with(appointment)

        subject.call
      end
    end

    context 'when it’s another type of user' do
      it 'does not enqueue the adjustment notifications job' do
        appointment.update_attribute(:accessibility_requirements, true)

        expect(AdjustmentNotificationsJob).not_to receive(:perform_later).with(appointment)

        subject.call
      end
    end
  end

  context 'when an appointment is updated to include printed consent' do
    it 'enqueues the third party printed consent form job' do
      appointment.update_attribute(:printed_consent_form_required, true)

      expect(PrintedThirdPartyConsentFormJob).to receive(:perform_later).with(appointment)

      subject.call
    end
  end

  context 'when an appointment is updated to include email consent' do
    it 'enqueues the third party consent form job' do
      appointment.update_attribute(:email_consent_form_required, true)

      expect(EmailThirdPartyConsentFormJob).to receive(:perform_later).with(appointment)

      subject.call
    end

    it 'enqueues the consent form email job when the consent email changes' do
      appointment.update(email_consent: 'smurfette@example.com', email_consent_form_required: true)

      expect(EmailThirdPartyConsentFormJob).to receive(:perform_later).with(appointment)

      subject.call
    end
  end

  context 'when a BSL appointment is completed' do
    it 'enqueues the BSL exit poll job to run in 24 hours' do
      scheduler = double(perform_later: true)
      appointment.update(bsl_video: true, status: :complete)

      expect(BslCustomerExitPollJob).to receive(:set).with(wait: 24.hours).and_return(scheduler)
      expect(scheduler).to receive(:perform_later).with(appointment)

      subject.call
    end
  end

  context 'when a DD appointment is completed' do
    it 'executes the DD reference number generation job synchronously' do
      appointment.update(schedule_type: 'due_diligence', status: :complete)

      expect(DueDiligenceReferenceNumberJob).to receive(:perform_now).with(appointment)

      subject.call
    end
  end

  context 'when the appointment is rescheduled' do
    it 'enqueues the rescheduled notifications' do
      new_guider = create(:guider)
      appointment.update_attribute(:guider_id, new_guider.id)

      expect(AppointmentRescheduledNotificationsJob).to receive(:perform_later).with(appointment)

      subject.call
    end

    context 'with a postal address' do
      it 'enqueues a printed confirmation' do
        appointment.update_attribute(:start_at, Time.zone.parse('2022-07-27 13:00'))

        expect(PrintedConfirmationJob).to receive(:perform_later).with(appointment)

        subject.call
      end
    end
  end

  context 'when the appointment is without an associated email' do
    it 'does not notify the customer' do
      expect(AppointmentMailer).not_to receive(:confirmation)

      appointment.update_attribute(:email, '')

      subject.call
    end
  end

  context 'and I update a core detail' do
    before { appointment.update_attribute(:first_name, 'Jean Ralphio') }

    it 'sends the customer a mail' do
      expect(AppointmentMailer).to receive(:updated).with(appointment)
      subject.call
    end

    it 'creates a CustomerUpdateActvity' do
      subject.call

      expect(CustomerUpdateActivity.last).to have_attributes(
        message: CustomerUpdateActivity::UPDATED_MESSAGE
      )
    end

    context 'but the appointment was in the past' do
      before { travel_to 2.weeks.from_now }
      after { travel_back }

      it 'does not send customer a mail' do
        expect(AppointmentMailer).not_to receive(:updated)
        subject.call
      end

      it 'does not create a CustomerUpdateActvity' do
        expect { subject.call }.to_not change { CustomerUpdateActivity.count }
      end
    end
  end

  context 'and I cancel the appointment' do
    before { appointment.update_attribute(:status, 'cancelled_by_pension_wise') }

    it 'sends the customer a mail' do
      expect(AppointmentMailer).to receive(:cancelled).with(appointment)
      subject.call
    end

    it 'creates a CustomerUpdateActvity' do
      subject.call

      expect(CustomerUpdateActivity.last).to have_attributes(
        message: CustomerUpdateActivity::CANCELLED_MESSAGE
      )
    end

    it 'alerts the resource managers' do
      expect(AppointmentCancelledNotificationsJob).to receive(:perform_later).with(appointment)

      subject.call
    end
  end

  context 'and I mark the appointment missed' do
    before { appointment.update_attribute(:status, 'no_show') }

    it 'sends the customer a mail' do
      expect(AppointmentMailer).to receive(:missed).with(appointment)
      subject.call
    end

    it 'creates a CustomerUpdateActvity' do
      subject.call

      expect(CustomerUpdateActivity.last).to have_attributes(
        message: CustomerUpdateActivity::MISSED_MESSAGE
      )
    end
  end
end
