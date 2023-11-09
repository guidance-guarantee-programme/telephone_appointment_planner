require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'POST /api/v1/nudge_appointments' do
  include ActiveJob::TestHelper

  scenario 'create a valid appointment' do
    travel_to '2022-04-23 12:00' do
      given_the_user_is_a_pension_wise_api_user do
        and_a_bookable_slot_exists_for_the_given_appointment_date
        and_a_resource_manager_exists
        when_the_client_posts_a_valid_appointment_request
        then_the_service_responds_with_a_201
        and_the_location_header_describes_the_booking_reference
        and_the_appointment_is_created
        and_the_customer_receives_a_confirmation_email
        and_the_resource_manager_receives_an_accessibility_notification
        and_the_resource_manager_receives_a_new_appointment_notification
      end
    end
  end

  scenario 'create an appointment with SMS confirmation' do
    travel_to '2022-04-23 12:00' do
      given_the_user_is_a_pension_wise_api_user do
        and_a_bookable_slot_exists_for_the_given_appointment_date
        and_a_resource_manager_exists
        when_the_client_posts_a_valid_appointment_request_with_sms_confirmation
        then_the_service_responds_with_a_201
        and_the_sms_confirmed_appointment_is_created
        and_the_customer_receives_an_sms_confirmation
      end
    end
  end

  def and_a_bookable_slot_exists_for_the_given_appointment_date
    @bookable_slot = create(:bookable_slot, start_at: Time.zone.parse('2022-04-28 12:10'))
  end

  def and_a_resource_manager_exists
    @resource_manager = create(:resource_manager)
  end

  def when_the_client_posts_a_valid_appointment_request
    @payload = {
      'start_at'                   => '2022-04-28T12:10:00.000Z',
      'first_name'                 => 'Rick',
      'last_name'                  => 'Sanchez',
      'email'                      => 'rick@example.com',
      'nudge_confirmation'         => 'email',
      'phone'                      => '02082524729',
      'memorable_word'             => 'snootboop',
      'date_of_birth'              => '1950-02-02',
      'accessibility_requirements' => '1',
      'notes'                      => 'These are my accessibility needs.',
      'nudge_eligibility_reason'   => '',
      'gdpr_consent'               => 'yes'
    }

    post api_v1_nudge_appointments_path, params: @payload, as: :json
  end

  def when_the_client_posts_a_valid_appointment_request_with_sms_confirmation
    @payload = {
      'start_at'                   => '2022-04-28T12:10:00.000Z',
      'first_name'                 => 'Rick',
      'last_name'                  => 'Sanchez',
      'email'                      => '',
      'mobile'                     => '07715930459',
      'nudge_confirmation'         => 'sms',
      'phone'                      => '02082524729',
      'memorable_word'             => 'snootboop',
      'date_of_birth'              => '1975-02-02',
      'accessibility_requirements' => '0',
      'notes'                      => '',
      'nudge_eligibility_reason'   => 'protected_pension_age',
      'gdpr_consent'               => 'yes'
    }

    post api_v1_nudge_appointments_path, params: @payload, as: :json
  end

  def and_the_sms_confirmed_appointment_is_created
    Appointment.last.tap do |appointment|
      expect(appointment).to have_attributes(
        start_at: Time.zone.parse('2022-04-28 12:10'),
        date_of_birth: Date.parse('1975-02-02'),
        first_name: 'Rick',
        last_name: 'Sanchez',
        email: '',
        nudge_confirmation: 'sms',
        mobile: '07715930459',
        phone: '02082524729',
        memorable_word: 'snootboop',
        dc_pot_confirmed: true,
        where_you_heard: 2,
        accessibility_requirements: false,
        nudge_eligibility_reason: 'protected_pension_age',
        gdpr_consent: 'yes'
      )

      expect(appointment).to be_pension_wise
      expect(appointment).to be_nudged
    end
  end

  def then_the_service_responds_with_a_201
    expect(response).to be_created
  end

  def and_the_location_header_describes_the_booking_reference
    expect(response.location).to end_with(appointment_path(Appointment.last))
  end

  def and_the_appointment_is_created
    Appointment.last.tap do |appointment|
      expect(appointment).to have_attributes(
        start_at: Time.zone.parse('2022-04-28 12:10'),
        date_of_birth: Date.parse('1950-02-02'),
        first_name: 'Rick',
        last_name: 'Sanchez',
        email: 'rick@example.com',
        nudge_confirmation: 'email',
        phone: '02082524729',
        memorable_word: 'snootboop',
        dc_pot_confirmed: true,
        where_you_heard: 2,
        gdpr_consent: 'yes',
        accessibility_requirements: true
      )

      expect(appointment).to be_pension_wise
      expect(appointment).to be_nudged
    end
  end

  def and_the_customer_receives_a_confirmation_email
    assert_enqueued_jobs(1, only: CustomerUpdateJob)
  end

  def and_the_resource_manager_receives_an_accessibility_notification
    assert_enqueued_jobs(1, only: AdjustmentNotificationsJob)
  end

  def and_the_resource_manager_receives_a_new_appointment_notification
    assert_enqueued_jobs(1, only: AppointmentCreatedNotificationsJob)
  end

  def and_the_customer_receives_an_sms_confirmation
    assert_enqueued_jobs(1, only: NudgeSmsAppointmentConfirmationJob)
  end
end
# rubocop:enable Metrics/BlockLength
