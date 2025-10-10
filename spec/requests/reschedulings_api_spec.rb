require 'rails_helper'

RSpec.describe 'POST /api/v1/appointments/{id}/reschedule' do # rubocop:disable Metrics/BlockLength
  before do
    [
      PusherAppointmentChangedJob,
      AppointmentRescheduledNotificationsJob,
      CustomerUpdateJob,
      RescheduleCasebookAppointmentJob,
      AppointmentRescheduledAwayNotificationsJob,
      SmsAppointmentConfirmationJob
    ].each do |expected_job|
      allow(expected_job).to receive(:perform_later)
    end
  end

  scenario 'Successfully rescheduling the appointment' do
    given_the_user_is_a_pension_wise_api_user do
      travel_to '2025-07-08 13:00' do
        and_a_pending_appointment_exists
        when_the_client_posts_a_valid_reschedule_request
        then_the_service_responds_with_a_200
        and_the_appointment_is_rescheduled
        and_the_rescheduling_reason_is_recorded
        and_a_customer_online_rescheduling_activity_is_created
        and_the_guider_is_notified
        and_the_previous_resource_managers_are_notified
        and_the_new_resource_managers_are_notified
        and_the_customer_receives_an_updated_email
        and_the_customer_receives_an_updated_sms
        and_a_casebook_rescheduling_is_enqueued
      end
    end
  end

  scenario 'Failure when rescheduling the appointment' do
    given_the_user_is_a_pension_wise_api_user do
      and_a_pending_appointment_exists
      when_the_client_posts_an_invalid_reschedule_request
      then_the_service_responds_with_a_422
    end
  end

  def when_the_client_posts_an_invalid_reschedule_request
    post api_v1_appointment_reschedule_path(@appointment, params: {}, as: :json)
  end

  def then_the_service_responds_with_a_422 # rubocop:disable Naming/VariableNumber
    expect(response.status).to eq(422)
  end

  def and_a_pending_appointment_exists
    @appointment     = create(:appointment, date_of_birth: '1970-01-01')
    @previous_guider = @appointment.guider
    @bookable_slot   = create(:bookable_slot, :cas, start_at: Time.zone.parse('2025-07-10 13:00'))

    @previous_start_at = @appointment.start_at
  end

  def when_the_client_posts_a_valid_reschedule_request
    @payload = {
      'reference' => @appointment.id,
      'date_of_birth' => '1970-01-01',
      'reason' => '1',
      'start_at' => @bookable_slot.start_at
    }

    post api_v1_appointment_reschedule_path(@appointment, params: @payload, as: :json)
  end

  def then_the_service_responds_with_a_200 # rubocop:disable Naming/VariableNumber
    expect(response).to be_ok
  end

  #  rubocop:disable Metrics/MethodLength
  def and_the_appointment_is_rescheduled
    expect(@appointment.reload).to have_attributes(
      start_at: @bookable_slot.start_at,
      guider_id: @bookable_slot.guider_id,
      rescheduling_reason: Appointment::CLIENT_RESCHEDULED,
      rescheduling_route: Appointment::RESCHEDULED_ONLINE
    )

    expect(@appointment.online_reschedules.first).to have_attributes(
      previous_guider_id: @previous_guider.id,
      previous_start_at: @previous_start_at
    )

    expect(@appointment.previous_guider_id).to eq(@previous_guider.id)
  end

  def and_the_rescheduling_reason_is_recorded
    expect(@appointment.online_rescheduling_reason).to eq('1')
  end

  def and_a_customer_online_rescheduling_activity_is_created
    expect(@appointment.activities.map(&:type)).to include(CustomerOnlineReschedulingActivity.to_s)
  end

  def and_the_guider_is_notified
    expect(PusherAppointmentChangedJob).to have_received(:perform_later).twice
  end

  def and_the_previous_resource_managers_are_notified
    expect(AppointmentRescheduledAwayNotificationsJob).to have_received(:perform_later)
  end

  def and_the_new_resource_managers_are_notified
    expect(AppointmentRescheduledNotificationsJob).to have_received(:perform_later)
  end

  def and_the_customer_receives_an_updated_email
    expect(CustomerUpdateJob).to have_received(:perform_later)
  end

  def and_the_customer_receives_an_updated_sms
    expect(SmsAppointmentConfirmationJob).to have_received(:perform_later)
  end

  def and_a_casebook_rescheduling_is_enqueued
    expect(RescheduleCasebookAppointmentJob).to have_received(:perform_later)
  end
end
