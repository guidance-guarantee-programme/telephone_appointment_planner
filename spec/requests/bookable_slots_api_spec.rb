require 'rails_helper'

RSpec.describe 'GET /api/v1/bookable_slots' do
  scenario 'retrieving Lloyds slots for the booking window' do
    travel_to '2017-01-09 12:00' do
      given_bookable_slots_for_the_booking_window_exist_across_providers
      when_the_client_requests_bookable_slots_for_lloyds
      then_the_response_contains_slots_filtered_for_lloyds
    end
  end

  scenario 'retrieving slots for the booking window' do
    travel_to '2017-01-09 12:00' do
      given_bookable_slots_for_the_booking_window_exist
      when_the_client_requests_bookable_slots
      then_the_response_contains_unique_slots_for_the_booking_window
    end
  end

  def given_bookable_slots_for_the_booking_window_exist_across_providers
    # included as CITA E&W
    create(:bookable_slot, :wallsend, start_at: Time.zone.parse('2017-01-14 14:00'))

    # included as PWNI
    create(:bookable_slot, :ni, start_at: Time.zone.parse('2017-01-15 14:00'))

    # excluded as TPAS
    create(:bookable_slot, start_at: Time.zone.parse('2017-01-16 14:00'))

    # excluded as TP
    create(:bookable_slot, :tp, start_at: Time.zone.parse('2017-01-17 14:00'))

    # excluded as CAS
    create(:bookable_slot, :cas, start_at: Time.zone.parse('2017-01-18 14:00'))
  end

  def when_the_client_requests_bookable_slots_for_lloyds
    get api_v1_bookable_slots_path(lloyds: true), as: :json
  end

  def then_the_response_contains_slots_filtered_for_lloyds
    expect(response).to be_ok

    JSON.parse(response.body).tap do |json|
      expect(json.keys).to eq(%w(2017-01-14 2017-01-15))
    end
  end

  def given_bookable_slots_for_the_booking_window_exist
    # one slot for one day
    create(:bookable_slot, start_at: Time.zone.parse('2017-01-13 14:00'))

    # three slots combined for one day
    create(:bookable_slot, start_at: Time.zone.parse('2017-01-16 15:00'))
    create_list(:bookable_slot, 2, start_at: Time.zone.parse('2017-01-16 12:00'))

    # falls within the booking window
    create(:bookable_slot, start_at: 2.days.from_now.advance(hours: 1))

    # in the window since it's TP with a short start
    create(:bookable_slot, :tp, start_at: 1.day.from_now)

    # included since the window is now 8 weeks
    create(:bookable_slot, start_at: 7.weeks.from_now)

    # falls after the booking window
    create(:bookable_slot, start_at: 9.weeks.from_now)
  end

  def when_the_client_requests_bookable_slots
    get api_v1_bookable_slots_path, as: :json
  end

  def then_the_response_contains_unique_slots_for_the_booking_window
    expect(response).to be_ok

    JSON.parse(response.body).tap do |json|
      expect(json['2017-01-16']).to eq(%w(2017-01-16T12:00:00.000Z 2017-01-16T15:00:00.000Z))

      expect(json.keys).to eq(%w(2017-01-11 2017-01-13 2017-01-16 2017-02-27))
    end
  end
end
