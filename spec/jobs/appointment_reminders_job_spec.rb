require 'rails_helper'

RSpec.describe AppointmentRemindersJob, '#perform' do
  before do
    allow(AppointmentMailer).to receive(:reminder).and_return(mailer_double)
    allow(mailer_double).to receive(:deliver_later)
  end

  let(:mailer_double) do
    double(:mailer)
  end

  let(:appointment) do
    create(
      :appointment,
      start_at: BusinessDays.from_now(10)
    )
  end

  def perform_job
    job = described_class.new
    5.times { job.perform }
  end

  context 'more than 24 hours until appointment' do
    it 'does not remind the customer' do
      perform_job

      expect(AppointmentMailer).to_not have_received(:reminder)
    end
  end

  context 'less than 24 hours until appointment' do
    it 'reminds the customer once' do
      travel_to(appointment.start_at - 5.hours) do
        perform_job
      end

      expect(AppointmentMailer).to have_received(:reminder).with(appointment).once
      expect(mailer_double).to have_received(:deliver_later).once
    end

    it 'creates a reminder activity' do
      travel_to(appointment.start_at - 5.hours) do
        perform_job
      end

      activity = appointment.activities.first
      expect(activity).to be_a(ReminderActivity)
      expect(activity.user).to eq current_user
      expect(activity.owner).to eq appointment.guider
    end

    context 'appointment is not pending' do
      context 'by the customer' do
        it 'does not remind the customer' do
          appointment.update!(status: 'cancelled_by_customer')
          travel_to(appointment.start_at - 5.hours) do
            perform_job
          end
          expect(AppointmentMailer).to_not have_received(:reminder)
        end
      end
    end

    context 'appointment has been rescheduled' do
      it 'reminds customers again once' do
        travel_to(appointment.start_at - 5.hours) do
          perform_job
        end

        appointment.update!(
          start_at: BusinessDays.from_now(20),
          end_at:   BusinessDays.from_now(20) + 1.hour
        )

        travel_to(appointment.start_at - 5.hours) do
          perform_job
        end

        expect(AppointmentMailer).to have_received(:reminder).with(appointment).twice
      end
    end
  end
end
