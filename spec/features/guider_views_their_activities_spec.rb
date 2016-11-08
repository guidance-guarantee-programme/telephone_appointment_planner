require 'rails_helper'

RSpec.feature 'Guider views their activities' do
  let(:guider) do
    create(:guider)
  end

  let(:someone) do
    create(:guider)
  end

  scenario 'Activies are loaded in realtime', js: true do
    given_a_browser_session_for guider do
      and_they_have_some_appointments
      when_they_view_their_activity
      then_they_see_all_activities
    end

    given_a_browser_session_for someone do
      when_they_leave_a_message_on_one_of_the_guiders_appointments
    end

    given_a_browser_session_for guider do
      then_they_see_the_new_activities
    end
  end

  def and_they_have_some_appointments
    @appointments = create_list(:appointment, 2, guider: guider)
  end

  def when_they_view_their_activity
    @page = Pages::Activities.new.tap(&:load)
  end

  def then_they_see_all_activities
    expect(@page.activities.map(&:text)).to match_array [
      "Someone assigned to #{current_user.name} less than a minute ago",
      "Someone assigned to #{current_user.name} less than a minute ago",
      'Someone created this appointment less than a minute ago',
      'Someone created this appointment less than a minute ago'
    ]
  end

  def when_they_leave_a_message_on_one_of_the_guiders_appointments
    page = Pages::EditAppointment.new
    page.load(id: @appointments.first.id)
    page.activity_feed.message.set('Hello mate')
    page.activity_feed.submit.click
  end

  def then_they_see_the_new_activities
    expect(@page).to have_dynamically_loaded_activities(count: 1, wait: 10)
    expect(@page.dynamically_loaded_activities.first.text).to eq(
      "#{someone.name} said Hello mate less than a minute ago"
    )
  end
end
