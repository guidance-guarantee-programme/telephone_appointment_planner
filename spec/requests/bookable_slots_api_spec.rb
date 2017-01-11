require 'rails_helper'

RSpec.describe 'GET /api/v1/bookable_slots' do
  scenario 'retrieving slots for the booking window' do
    travel_to '2017-01-10 12:00' do
      given_the_user_is_a_pension_wise_api_user do
        and_bookable_slots_for_the_booking_window_exist
        when_they_request_bookable_slots
        then_the_response_contains_unique_slots_for_the_booking_window
      end
    end
  end

  def and_bookable_slots_for_the_booking_window_exist
    # three slots combined for one day
    create(:bookable_slot, start_at: Time.zone.parse('2017-01-12 15:00'))
    create_list(:bookable_slot, 2, start_at: Time.zone.parse('2017-01-12 12:00'))

    # one slot for one day
    create(:bookable_slot, start_at: Time.zone.parse('2017-01-13 14:00'))

    # falls before the booking window
    create(:bookable_slot, start_at: 1.day.from_now)

    # falls after the booking window
    create(:bookable_slot, start_at: 7.weeks.from_now)
  end

  def when_they_request_bookable_slots
    get api_v1_bookable_slots_path, as: :json
  end

  def then_the_response_contains_unique_slots_for_the_booking_window
    expect(response).to be_ok

    JSON.parse(response.body).tap do |json|
      expect(json.count).to eq(2)

      expect(json['2017-01-12']).to eq(%w(12:00 15:00))

      expect(json['2017-01-13']).to eq(%w(14:00))
    end
  end
end
