require 'rails_helper'

RSpec.describe 'POST /api/v1/appointments' do
  include ActiveJob::TestHelper

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
        and_the_resource_manager_receives_an_accessibility_notification
        and_the_resource_manager_receives_a_new_appointment_notification
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
      'accessibility_requirements' => 'false'
    }

    post api_v1_appointments_path, params: @payload, as: :json
  end

  def then_the_service_responds_with_a_422
    expect(response).to be_unprocessable
  end

  def and_the_errors_are_serialized_in_the_response
    JSON.parse(response.body).tap do |json|
      expect(json.keys).to eq(%w(first_name last_name))
    end
  end

  def and_a_bookable_slot_exists_for_the_given_appointment_date
    @bookable_slot = create(:bookable_slot, start_at: Time.zone.parse('2017-01-13 12:10'))
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
      'phone'            => '02082524729',
      'memorable_word'   => 'snootboop',
      'date_of_birth'    => '1950-02-02',
      'dc_pot_confirmed' => true,
      'where_you_heard'  => '1',
      'gdpr_consent'     => nil,
      'accessibility_requirements' => true,
      'notes' => 'I am hard of hearing',
      'lloyds_signposted' => true
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
      'gdpr_consent'     => nil,
      'accessibility_requirements' => true,
      'notes' => 'I am hard of hearing',
      'smarter_signposted' => true,
      'lloyds_signposted' => false
    }

    post api_v1_appointments_path, params: @payload, as: :json
  end

  def and_the_appointment_is_created_as_a_smarter_signposted_appointment
    expect(Appointment.last).to be_smarter_signposted
  end

  def then_the_service_responds_with_a_201
    expect(response).to be_created
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
        phone: '02082524729',
        memorable_word: 'snootboop',
        dc_pot_confirmed: true,
        where_you_heard: 1,
        gdpr_consent: '',
        accessibility_requirements: true,
        notes: 'I am hard of hearing',
        pension_provider: 'n/a',
        lloyds_signposted: true
      )
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
end
