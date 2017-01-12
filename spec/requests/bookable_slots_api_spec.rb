require 'rails_helper'

RSpec.describe 'GET /api/v1/bookable_slots' do
  scenario 'retrieving slots for the booking window' do
    travel_to '2017-01-10 12:00' do
      given_bookable_slots_for_the_booking_window_exist
      when_the_client_requests_bookable_slots
      then_the_response_contains_unique_slots_for_the_booking_window
    end
  end

  def given_bookable_slots_for_the_booking_window_exist
    # one slot for one day
    create(:bookable_slot, start_at: Time.zone.parse('2017-01-13 14:00'))

    # three slots combined for one day
    create(:bookable_slot, start_at: Time.zone.parse('2017-01-12 15:00'))
    create_list(:bookable_slot, 2, start_at: Time.zone.parse('2017-01-12 12:00'))

    # falls before the booking window
    create(:bookable_slot, start_at: 1.day.from_now)

    # falls after the booking window
    create(:bookable_slot, start_at: 7.weeks.from_now)
  end

  def when_the_client_requests_bookable_slots
    get api_v1_bookable_slots_path, as: :json
  end

  def then_the_response_contains_unique_slots_for_the_booking_window
    expect(response).to be_ok

    JSON.parse(response.body).tap do |json|
      expect(json['2017-01-12']).to eq(%w(2017-01-12T12:00:00.000Z 2017-01-12T15:00:00.000Z))

      expect(json['2017-01-13']).to eq(%w(2017-01-13T14:00:00.000Z))

      expect(json.keys).to eq(%w(2017-01-12 2017-01-13))
    end
  end
end
