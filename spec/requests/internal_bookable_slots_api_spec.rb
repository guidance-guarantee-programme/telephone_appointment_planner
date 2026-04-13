require 'rails_helper'

RSpec.describe 'GET /bookable_slots' do
  scenario 'Resource managers retrieving available slots in timezone' do
    given_the_user_is_a_resource_manager do
      and_bookable_slots_exist
      when_the_client_requests_bookable_slots
      then_they_do_not_include_slots_in_the_current_hour
    end
  end

  def and_bookable_slots_exist
    create(:bookable_slot, start_at: Time.zone.parse('2026-04-12 13:00'))
  end

  def when_the_client_requests_bookable_slots
    travel_to Time.zone.parse('2026-04-12 12:30') do
      get internal_bookable_slots_path(
        schedule_type: 'pension_wise',
        rescheduling: false,
        start: '2026-04-12',
        end: '2026-04-16'
      ), as: :json
    end
  end

  def then_they_do_not_include_slots_in_the_current_hour
    expect(JSON.parse(response.body)).to be_empty
  end
end
