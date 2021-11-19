require 'rails_helper'
require 'securerandom'

RSpec.describe 'POST /sms_cancellations', type: :request do
  include ActiveJob::TestHelper

  scenario 'unauthorised access' do
    when_the_client_makes_an_unauthorised_request
    then_the_service_does_not_grant_access
  end

  scenario 'successfully cancelling an existing Pension Wise appointment' do
    given_pending_appointments_exist
    when_the_client_requests_cancellation_by_sms
    then_the_service_responds_no_content
    and_the_appointment_is_cancelled
    and_a_cancellation_activity_is_created
    and_the_customer_is_sent_a_confirmation_sms
    and_the_guider_is_notified
    and_the_resource_managers_are_notified
  end

  def given_pending_appointments_exist
    @appointment   = create(:appointment, mobile: '07715930455')
    @due_diligence = create(:appointment, :due_diligence, mobile: '07715930455')
  end

  def when_the_client_requests_cancellation_by_sms
    ENV['NOTIFY_CALLBACK_BEARER_TOKEN'] = 'deadbeef'

    token   = ActionController::HttpAuthentication::Token.encode_credentials('deadbeef')
    headers = { 'HTTP_AUTHORIZATION' => token, 'CONTENT_TYPE' => 'application/json' }
    payload = { 'source_number' => '447715 930 455', 'message' => 'Cancel', schedule_type: 'pension_wise' }

    post sms_cancellations_path, params: payload.to_json, headers: headers
  end

  def then_the_service_responds_no_content
    expect(response).to be_no_content
  end

  def and_the_appointment_is_cancelled
    @appointment.reload

    expect(@appointment).to be_cancelled_by_customer_sms
  end

  def and_a_cancellation_activity_is_created
    expect(@appointment.activities.first).to be_an(SmsCancellationActivity)
  end

  def and_the_customer_is_sent_a_confirmation_sms
    assert_enqueued_jobs(1, only: SmsCancellationSuccessJob)
  end

  def and_the_guider_is_notified
    assert_enqueued_jobs(1, only: PusherAppointmentChangedJob)
  end

  def and_the_resource_managers_are_notified
    assert_enqueued_jobs(1, only: AppointmentCancelledNotificationsJob)
  end

  def when_the_client_makes_an_unauthorised_request
    ENV['NOTIFY_CALLBACK_BEARER_TOKEN'] = 'welp'
    token = ActionController::HttpAuthentication::Token.encode_credentials('deadbeef')

    post sms_cancellations_path, headers: { 'HTTP_AUTHORIZATION' => token }
  end

  def then_the_service_does_not_grant_access
    expect(response.location).to end_with('/auth/gds')
  end
end
