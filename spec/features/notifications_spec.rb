require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Activity notification alerts', js: true do
  let(:agent) do
    create(:agent)
  end

  let(:guider) do
    create(:guider)
  end

  scenario 'A new high priority activity occurs' do
    skip 'this is flakey, will address'

    given_a_browser_session_for(guider, agent) do
      when_they_are_on_their_dashboard
    end

    and_they_have_an_appointment
    and_a_high_priority_activity_occurs

    given_a_browser_session_for(agent) do
      then_they_see_there_is_a_notification
    end

    given_a_browser_session_for(guider) do
      then_they_have_no_notifications
    end
  end

  scenario 'Viewing high priority activities' do
    given_a_browser_session_for(guider, agent) do
      when_they_are_on_their_dashboard
    end

    and_they_have_an_appointment
    and_a_high_priority_activity_occurs

    given_a_browser_session_for(agent) do
      and_they_click_on_the_high_priority_activity_badge
      and_they_can_see_their_high_priority_alerts
    end

    given_a_browser_session_for(guider) do
      and_they_click_on_the_high_priority_activity_badge
      then_they_can_see_no_high_priority_alerts_message
    end
  end

  scenario 'No high priority activities' do
    given_a_browser_session_for(guider, agent) do
      when_they_are_on_their_dashboard
      and_they_click_on_the_high_priority_activity_badge
      then_they_can_see_no_high_priority_alerts_message
    end
  end

  scenario 'Resolving a high priority activity' do
    given_a_browser_session_for(guider, agent) do
      and_they_have_an_appointment
      and_a_high_priority_activity_occurs
      when_they_are_viewing_the_appointment
      then_they_can_see_the_high_priority_activity
      and_when_they_resolve_the_high_priority_activity
      then_the_high_priority_activity_is_resolved
    end
  end
end

def and_they_have_an_appointment
  start_at = BusinessDays.from_now(10).change(hour: 9)
  @appointment ||= create(:appointment, start_at: start_at, guider: guider, agent: agent)
end

def when_they_are_on_their_dashboard
  visit '/allocations'
  @page = Pages::Base.new
end

def when_they_are_viewing_the_appointment
  @page = Pages::EditAppointment.new
  @page.load(id: @appointment.id)
end

def and_a_high_priority_activity_occurs
  DropActivity.from('an event', 'an event description', 'booking_created', @appointment)
end

def and_they_click_on_the_high_priority_activity_badge
  @page.high_priority_toggle.click
end

def then_they_see_there_is_a_notification
  expect(@page.high_priority_count.text).to eq('1')
end

def then_they_have_no_notifications
  expect(@page).to have_no_high_priority_count
end

def and_they_can_see_their_high_priority_alerts
  expect(@page.high_priority_activities).to have_content 'an event description'
end

def then_they_can_see_no_high_priority_alerts_message
  expect(@page.no_activities).to be_visible
end

def then_they_can_see_the_high_priority_activity
  expect(@page.activity_feed.high_priority_activities).to be_present
end

def and_when_they_resolve_the_high_priority_activity
  @page.activity_feed.resolve_activity_button.click
end

def then_the_high_priority_activity_is_resolved
  expect(@page.activity_feed.high_priority_activities.first).to have_content('Resolved Successfully')
end
# rubocop:enable Metrics/BlockLength
