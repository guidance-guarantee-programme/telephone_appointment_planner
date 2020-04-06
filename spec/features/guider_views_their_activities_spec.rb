require 'rails_helper'

RSpec.feature 'Guider views their activities' do
  let(:guider) do
    create(:guider)
  end

  let(:someone) do
    create(:guider)
  end

  scenario 'No activities' do
    given_a_browser_session_for(guider) do
      and_they_have_no_appointments
      when_they_view_their_activity
      then_they_see_a_no_activity_message
    end
  end

  scenario 'Activities are visible statically' do
    given_a_browser_session_for(guider) do
      and_they_have_some_appointments
      when_they_view_their_activity
      then_they_see_all_activities
    end
  end

  def and_they_have_some_appointments
    @appointments = create_list(:appointment, 2, guider: guider)
  end

  def and_they_have_no_appointments
    @appointments = []
  end

  def when_they_view_their_activity
    @page = Pages::Activities.new.tap(&:load)
  end

  def then_they_see_all_activities
    expect(@page.activities.map(&:text)).to match_array [
      a_string_including('assigned this appointment to'),
      a_string_including('assigned this appointment to'),
      a_string_including('created'),
      a_string_including('created')
    ]
  end

  def then_they_see_a_no_activity_message
    expect(@page).to have_no_activity
  end
end
