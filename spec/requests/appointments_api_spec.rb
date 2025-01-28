require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'POST /api/v1/appointments' do
  include ActiveJob::TestHelper

  context 'due diligence appointments' do
    scenario 'supplying an incorrect schedule type' do
      given_the_user_is_a_pension_wise_api_user do
        when_the_client_supplies_an_incorrect_schedule_type
        then_the_api_responds_unprocessable
      end
    end

    scenario 'successfully creating a due diligence appointment' do
      travel_to '2021-09-01 12:00' do
        given_the_user_is_a_pension_wise_api_user do
          and_bookable_slots_exist_for_due_diligence
          when_the_client_posts_a_due_diligence_appointment_request
          then_the_service_responds_with_a_201
          and_the_due_diligence_appointment_is_created
        end
      end
    end
  end

  scenario 'creating a smarter-signposted appointment' do
    travel_to '2017-01-10 12:00' do
      given_the_user_is_a_pension_wise_api_user do
        and_a_bookable_slot_exists_for_the_given_appointment_date
        when_the_client_posts_a_smarter_signposted_appointment_request
        then_the_service_responds_with_a_201
        and_the_appointment_is_created_as_a_smarter_signposted_appointment
      end
    end
  end

  scenario 'creating a nudged appointment' do
    travel_to '2017-01-10 12:00' do
      given_the_user_is_a_pension_wise_api_user do
        and_a_bookable_slot_exists_for_the_given_appointment_date
        when_the_client_posts_a_nudged_appointment_request
        then_the_service_responds_with_a_201
        and_the_appointment_is_created_as_a_nudged_appointment
      end
    end
  end

  scenario 'create a valid appointment' do
    travel_to '2017-01-10 12:00' do
      given_the_user_is_a_pension_wise_api_user do
        and_a_bookable_slot_exists_for_the_given_appointment_date
        and_a_resource_manager_exists
        when_the_client_posts_a_valid_appointment_request
        then_the_service_responds_with_a_201
        and_the_location_header_describes_the_booking_reference
        and_the_appointment_is_created
        and_the_customer_receives_a_confirmation_email
        and_the_customer_receives_a_confirmation_sms
        and_the_resource_manager_receives_an_accessibility_notification
        and_the_resource_manager_receives_a_new_appointment_notification
        and_the_system_attempts_to_push_to_casebook
      end
    end
  end

  scenario 'attempting to create an invalid appointment' do
    travel_to '2017-01-10 12:00' do
      given_the_user_is_a_pension_wise_api_user do
        and_a_bookable_slot_exists_for_the_given_appointment_date
        when_the_client_posts_an_invalid_appointment_request
        then_the_service_responds_with_a_422
        and_the_errors_are_serialized_in_the_response
      end
    end
  end

  scenario 'when a customer journey booking is placed' do
    travel_to '2023-10-04 13:00' do
      given_the_user_is_a_pension_wise_api_user do
        and_an_unbookable_tpas_slot_exists
        and_a_cita_bookable_slot_exists
        when_the_client_posts_the_appointment_request
        then_the_service_responds_with_a_201
        and_the_appointment_is_correctly_allocated_to_cita
      end
    end
  end

  def and_an_unbookable_tpas_slot_exists
    # create lots of these to work the random allocator
    create_list(:bookable_slot, 10, start_at: Time.zone.parse('2023-10-08 14:00'))
  end

  def and_a_cita_bookable_slot_exists
    @expected = create(:bookable_slot, :north_tyneside, start_at: Time.zone.parse('2023-10-08 14:00'))
  end

  def when_the_client_posts_the_appointment_request
    @payload = {
      'start_at'                   => '2023-10-08 14:00:00 UTC',
      'first_name'                 => 'George',
      'last_name'                  => 'Daisy',
      'email'                      => 'george@example.com',
      'phone'                      => '07715930455',
      'memorable_word'             => 'Cheesy',
      'date_of_birth'              => '1970-01-01',
      'dc_pot_confirmed'           => false,
      'where_you_heard'            => '2',
      'gdpr_consent'               => 'no',
      'accessibility_requirements' => false,
      'adjustments'                => '',
      'notes'                      => '',
      'smarter_signposted'         => false,
      'lloyds_signposted'          => false,
      'referrer'                   => 'MMM',
      'rebooked_from_id'           => '1234567'
    }

    post api_v1_appointments_path, params: @payload, as: :json
  end

  def and_the_appointment_is_correctly_allocated_to_cita
    expect(Appointment.last.guider_id).to eq(@expected.guider_id)
  end

  def and_a_due_diligence_slot_exists
    create(:bookable_slot, :due_diligence, start_at: Time.zone.parse('2021-12-06 17:20'))
  end

  def when_the_client_attempts_to_book_the_slot
    @payload = {
      'start_at'                   => '2021-12-06 17:20:00 UTC',
      'first_name'                 => 'Ben',
      'last_name'                  => 'Jones',
      'email'                      => 'ben@example.com',
      'phone'                      => '07715930455',
      'memorable_word'             => 'Cheese',
      'date_of_birth'              => '1970-01-01',
      'dc_pot_confirmed'           => false,
      'where_you_heard'            => '2',
      'gdpr_consent'               => 'no',
      'accessibility_requirements' => false,
      'adjustments'                => '',
      'notes'                      => '',
      'smarter_signposted'         => false,
      'lloyds_signposted'          => false,
      'schedule_type'              => 'due_diligence',
      'referrer'                   => 'MMM'
    }

    post api_v1_appointments_path, params: @payload, as: :json
  end

  def and_bookable_slots_exist_for_due_diligence
    create(:bookable_slot, :due_diligence, start_at: Time.zone.parse('2021-09-16 13:00'))
  end

  def when_the_client_posts_a_due_diligence_appointment_request
    @payload = {
      'start_at'          => '2021-09-16T13:00:00.000Z',
      'first_name'        => 'Rick',
      'last_name'         => 'Sanchez',
      'email'             => 'rick@example.com',
      'phone'             => '02082524729',
      'memorable_word'    => 'snootboop',
      'date_of_birth'     => '1950-02-02',
      'dc_pot_confirmed'  => true,
      'where_you_heard'   => '1',
      'gdpr_consent'      => 'yes',
      'lloyds_signposted' => false,
      'schedule_type'     => 'due_diligence',
      'referrer'          => 'Big Pension Co.',
      'country_code'      => 'FR',
      'accessibility_requirements' => false,
      'adjustments' => ''
    }

    post api_v1_appointments_path, params: @payload, as: :json
  end

  def then_the_service_responds_with_a_201
    expect(response).to be_created
  end

  def and_the_due_diligence_appointment_is_created
    expect(Appointment.last).to have_attributes(
      schedule_type: 'due_diligence',
      country_code: 'FR',
      attended_digital: nil
    )
  end

  def when_the_client_supplies_an_incorrect_schedule_type
    @payload = { 'schedule_type' => 'bad_times' }

    post api_v1_appointments_path, params: @payload, as: :json
  end

  def then_the_api_responds_unprocessable
    expect(response).to be_unprocessable
  end

  def when_the_client_posts_an_invalid_appointment_request
    @payload = {
      'start_at'         => '2017-01-13T12:10:00.000Z',
      'first_name'       => '',
      'last_name'        => '',
      'email'            => 'rick@example.com',
      'phone'            => '02082524729',
      'memorable_word'   => 'snootboop',
      'date_of_birth'    => '1950-02-02',
      'dc_pot_confirmed' => true,
      'where_you_heard'  => '1',
      'gdpr_consent'     => 'yes',
      'adjustments'      => '',
      'accessibility_requirements' => false
    }

    post api_v1_appointments_path, params: @payload, as: :json
  end

  def then_the_service_responds_with_a_422
    expect(response).to be_unprocessable
  end

  def and_the_errors_are_serialized_in_the_response
    JSON.parse(response.body).tap do |json|
      expect(json.keys).to eq(%w[first_name last_name])
    end
  end

  def and_a_bookable_slot_exists_for_the_given_appointment_date
    @bookable_slot = create(:bookable_slot, :north_tyneside, start_at: Time.zone.parse('2017-01-13 12:10'))
  end

  def and_a_resource_manager_exists
    @resource_manager = create(:resource_manager)
  end

  def when_the_client_posts_a_valid_appointment_request
    @payload = {
      'start_at'         => '2017-01-13T12:10:00.000Z',
      'first_name'       => 'Rick',
      'last_name'        => 'Sanchez',
      'email'            => 'rick@example.com',
      'phone'            => '07010123456',
      'memorable_word'   => 'snootboop',
      'date_of_birth'    => '1950-02-02',
      'dc_pot_confirmed' => true,
      'where_you_heard'  => '1',
      'gdpr_consent'     => 'yes',
      'accessibility_requirements' => true,
      'adjustments'      => 'I am hard of hearing',
      'notes'            => '',
      'lloyds_signposted' => true,
      'rebooked_from_id'  => '1234567',
      'attended_digital'  => 'yes'
    }

    post api_v1_appointments_path, params: @payload, as: :json
  end

  def when_the_client_posts_a_smarter_signposted_appointment_request
    @payload = {
      'start_at'         => '2017-01-13T12:10:00.000Z',
      'first_name'       => 'Rick',
      'last_name'        => 'Sanchez',
      'email'            => 'rick@example.com',
      'phone'            => '02082524729',
      'memorable_word'   => 'snootboop',
      'date_of_birth'    => '1950-02-02',
      'dc_pot_confirmed' => true,
      'where_you_heard'  => '1',
      'gdpr_consent'     => 'yes',
      'accessibility_requirements' => true,
      'adjustments' => 'I am hard of hearing',
      'smarter_signposted' => true,
      'lloyds_signposted' => false
    }

    post api_v1_appointments_path, params: @payload, as: :json
  end

  def when_the_client_posts_a_nudged_appointment_request
    @payload = {
      'start_at'         => '2017-01-13T12:10:00.000Z',
      'first_name'       => 'Rick',
      'last_name'        => 'Sanchez',
      'email'            => 'rick@example.com',
      'phone'            => '02082524729',
      'memorable_word'   => 'snootboop',
      'date_of_birth'    => '1950-02-02',
      'dc_pot_confirmed' => true,
      'where_you_heard'  => '1',
      'gdpr_consent'     => 'yes',
      'accessibility_requirements' => true,
      'adjustments' => 'I am hard of hearing',
      'smarter_signposted' => false,
      'lloyds_signposted' => false,
      'nudged' => true
    }

    post api_v1_appointments_path, params: @payload, as: :json
  end

  def and_the_appointment_is_created_as_a_nudged_appointment
    expect(Appointment.last).to have_attributes(
      nudged: true,
      attended_digital: nil
    )
  end

  def and_the_appointment_is_created_as_a_smarter_signposted_appointment
    expect(Appointment.last).to be_smarter_signposted
  end

  def and_the_location_header_describes_the_booking_reference
    expect(response.location).to end_with(appointment_path(Appointment.last))
  end

  def and_the_appointment_is_created
    Appointment.last.tap do |appointment|
      expect(appointment.guider).to be_present
      expect(appointment.agent).to  be_present

      expect(appointment).to have_attributes(
        start_at: Time.zone.parse('2017-01-13 12:10'),
        end_at: Time.zone.parse('2017-01-13 13:10'),
        date_of_birth: Date.parse('1950-02-02'),
        first_name: 'Rick',
        last_name: 'Sanchez',
        email: 'rick@example.com',
        country_code: 'GB',
        phone: '07010123456',
        memorable_word: 'snootboop',
        dc_pot_confirmed: true,
        where_you_heard: 1,
        gdpr_consent: 'yes',
        accessibility_requirements: true,
        adjustments: 'I am hard of hearing',
        pension_provider: 'n/a',
        lloyds_signposted: true,
        rebooked_from_id: 1_234_567,
        attended_digital: 'yes'
      )

      # defaults to pension wise when the schedule type is unspecified
      expect(appointment).to be_pension_wise
    end
  end

  def and_the_customer_receives_a_confirmation_email
    assert_enqueued_jobs(1, only: CustomerUpdateJob)
  end

  def and_the_customer_receives_a_confirmation_sms
    assert_enqueued_jobs(1, only: SmsAppointmentConfirmationJob)
  end

  def and_the_resource_manager_receives_an_accessibility_notification
    assert_enqueued_jobs(1, only: AdjustmentNotificationsJob)
  end

  def and_the_resource_manager_receives_a_new_appointment_notification
    assert_enqueued_jobs(1, only: AppointmentCreatedNotificationsJob)
  end

  def and_the_system_attempts_to_push_to_casebook
    assert_enqueued_jobs(1, only: PushCasebookAppointmentJob)
  end
end
# rubocop:enable Metrics/BlockLength
