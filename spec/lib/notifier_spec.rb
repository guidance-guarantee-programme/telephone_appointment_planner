require 'rails_helper'

# rubocop:disable Metrics/BlockLength
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
    allow(AppointmentMailer).to receive(:potential_duplicates) { mailer }
    allow(mailer).to receive(:deliver_now)
    allow(mailer).to receive(:deliver_later)
  end

  context 'when the appointment has potential duplicates' do
    context 'when the appointment is pending' do
      it 'sends the correct email notification' do
        allow(appointment).to receive(:potential_duplicates?).and_return(true)
        expect(AppointmentMailer).to receive(:potential_duplicates).and_return(mailer)
        expect(mailer).to receive(:deliver_later)

        subject.call
      end
    end

    context 'when the appointment is not pending' do
      it 'does not send the notification' do
        allow(appointment).to receive(:pending?).and_return(false)
        allow(appointment).to receive(:potential_duplicates?).and_return(true)
        expect(AppointmentMailer).not_to receive(:potential_duplicates)

        subject.call
      end
    end
  end

  context 'when an appointment is otherwise altered' do
    context 'when effected by a TPAS `agent`' do
      let(:modifying_agent) { create(:resource_manager, :tpas) }

      context 'when the changed attribute should notify' do
        it 'updates the resource managers' do
          appointment.update_attribute(:guider_id, create(:guider, :cas).id)
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

      context 'when the appointment belongs to tpas/ops' do
        it 'does not update resource managers' do
          appointment.update_attribute(:guider_id, create(:guider, :tpas).id)
          appointment.update_attribute(:last_name, 'Smithson')

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
    context 'when the person effecting the change is a TPAS `agent`' do
      let(:modifying_agent) { create(:resource_manager, :tpas) }

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

  context 'when a BSL appointment is completed' do
    it 'enqueues the BSL exit poll job to run in 24 hours' do
      scheduler = double(perform_later: true)
      appointment.update(bsl_video: true, status: :complete)

      expect(BslCustomerExitPollJob).to receive(:set).with(wait: 24.hours).and_return(scheduler)
      expect(SummaryDocumentCheckJob).to receive(:set).with(wait: 24.hours).and_return(double(perform_later: true))
      expect(scheduler).to receive(:perform_later).with(appointment)

      subject.call
    end
  end

  context 'when any appointment is completed' do
    it 'enqueues the summary document check to run in 24 hours' do
      scheduler = double(perform_later: true)
      appointment.update(status: :complete)

      expect(SummaryDocumentCheckJob).to receive(:set).with(wait: 24.hours).and_return(scheduler)
      expect(scheduler).to receive(:perform_later).with(appointment)

      subject.call
    end
  end

  context 'when a DD appointment is completed' do
    it 'executes the DD reference number generation job synchronously' do
      scheduler = double(perform_later: true)
      appointment.update(schedule_type: 'due_diligence', status: :complete)

      expect(DueDiligenceReferenceNumberJob).to receive(:perform_now).with(appointment)
      expect(SummaryDocumentCheckJob).to receive(:set).with(wait: 24.hours).and_return(scheduler)
      expect(scheduler).to receive(:perform_later).with(appointment)

      subject.call
    end
  end

  context 'when the appointment is rescheduled' do
    let(:guider) { create(:guider) }

    before { appointment.update_attribute(:guider_id, guider.id) }

    it 'enqueues the rescheduled notifications' do
      expect(AppointmentRescheduledNotificationsJob).to receive(:perform_later).with(appointment)

      subject.call
    end

    context 'with a postal address' do
      context 'when the appointment is rescheduled by date/time' do
        it 'enqueues a printed confirmation' do
          appointment.update_attribute(:start_at, Time.zone.parse('2022-07-27 13:00'))

          expect(PrintedConfirmationJob).to receive(:perform_later).with(appointment)

          subject.call
        end
      end

      context 'when the appointment is only reallocated' do
        it 'does not enqueue a printed confirmation' do
          expect(PrintedConfirmationJob).to_not receive(:perform_later).with(appointment)

          subject.call
        end
      end
    end

    it 'enqueues a casebook appointment changed job' do
      expect(RescheduleCasebookAppointmentJob).to receive(:perform_later).with(appointment)

      subject.call
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
        expect { subject.call }.to_not(change { CustomerUpdateActivity.count })
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

    it 'enqueues a casebook cancellation job' do
      expect(CancelCasebookAppointmentJob).to receive(:perform_later).with(appointment)

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

  context 'when the `rescheduled_at` column is touched' do
    it 'does not send a customer email' do
      expect(CustomerUpdateJob).to_not receive(:perform_later)

      appointment.touch(:rescheduled_at)

      subject.call
    end
  end
end
# rubocop:enable Metrics/BlockLength
