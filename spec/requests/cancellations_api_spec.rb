require 'rails_helper'

RSpec.describe 'POST /api/v1/appointments/{id}/cancel' do # rubocop:disable Metrics/BlockLength
  include ActiveJob::TestHelper

  scenario 'successfully cancelling the appointment' do
    given_the_user_is_a_pension_wise_api_user do
      and_a_pending_appointment_exists
      when_the_client_posts_a_valid_cancellation_request
      then_the_service_responds_with_a_201
      and_the_appointment_is_cancelled
      and_a_customer_online_cancellation_activity_is_created
      and_the_guider_is_notified
      and_the_resource_managers_are_notified
      and_the_customer_receives_a_cancellation_email
      and_the_customer_receives_a_cancellation_sms
      and_a_casebook_cancellation_is_enqueued
    end
  end

  def and_a_pending_appointment_exists
    @appointment = create(:appointment, date_of_birth: '1970-01-01')
  end

  def when_the_client_posts_a_valid_cancellation_request
    @payload = { 'date_of_birth' => '1970-01-01' }

    post api_v1_appointment_cancel_path(@appointment, params: @payload, as: :json)
  end

  def then_the_service_responds_with_a_201 # rubocop:disable Naming/VariableNumber
    expect(response.status).to eq(201)
  end

  def and_the_appointment_is_cancelled
    expect(@appointment.reload).to be_cancelled_by_customer_online
  end

  def and_a_customer_online_cancellation_activity_is_created
    expect(@appointment.activities.first).to be_an(CustomerOnlineCancellationActivity)
  end

  def and_the_guider_is_notified
    assert_enqueued_jobs(1, only: PusherAppointmentChangedJob)
  end

  def and_the_resource_managers_are_notified
    assert_enqueued_jobs(1, only: AppointmentCancelledNotificationsJob)
  end

  def and_the_customer_receives_a_cancellation_email
    assert_enqueued_jobs(1, only: CustomerUpdateJob)
  end

  def and_the_customer_receives_a_cancellation_sms
    assert_enqueued_jobs(1, only: SmsCancellationSuccessJob)
  end

  def and_a_casebook_cancellation_is_enqueued
    assert_enqueued_jobs(1, only: CancelCasebookAppointmentJob)
  end
end
