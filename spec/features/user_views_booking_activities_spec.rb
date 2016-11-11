require 'rails_helper'

RSpec.feature 'User views appointment activities' do
  scenario 'User creates a message activity', js: true do
    given_the_user_has_no_permissions do
      and_there_is_an_appointment
      when_they_view_the_appointment
      and_they_leave_a_message
      then_they_see_their_new_message
      and_the_message_field_is_cleared
    end
  end

  scenario 'User views activities', js: true do
    given_the_user_has_no_permissions do
      and_there_is_an_appointment
      and_the_appointment_was_updated_multiple_times
      when_they_view_the_appointment
      then_they_see_the_last_activity
      when_they_request_further_activities
      then_they_see_all_the_activities
      when_somebody_else_adds_an_activity
      then_it_appears_dynamically
    end
  end

  def and_there_is_an_appointment
    @appointment = create(:appointment, guider: current_user)
  end

  def when_they_view_the_appointment
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
  end

  def and_they_leave_a_message
    @page.activity_feed.tap do |feed|
      feed.message.set('This is my message')
      feed.submit.click
    end
  end

  def then_they_see_their_new_message
    expect(@page.activity_feed).to have_text('This is my message')
  end

  def and_the_message_field_is_cleared
    expect(@page.activity_feed.message.value).to eq('')
  end

  def and_the_appointment_was_updated_multiple_times
    @appointment.update(first_name: 'Mortimer')
    @appointment.update(email: 'mortimer@example.com')
  end

  def then_they_see_the_last_activity
    @page.activity_feed.tap do |feed|
      expect(feed).to have_activities(count: 1)
      expect(feed.activities.first).to have_text('email')
    end
  end

  def when_they_request_further_activities
    @page.activity_feed.further_activities.click
  end

  def then_they_see_all_the_activities
    @page.activity_feed.tap do |feed|
      feed.wait_until_hidden_activities_visible

      expect(feed).to have_activities(count: 4)
      expect(feed.activities.last).to have_text('created')
    end
  end

  def when_somebody_else_adds_an_activity
    AuditActivity.from(
      OpenStruct.new(
        user_id: current_user.id,
        audited_changes: { 'thing' => nil },
        appointment_id: @appointment.id
      ),
      @appointment
    )
  end

  def then_it_appears_dynamically
    expect(@page.activity_feed).to have_activities(count: 5, wait: 10)
    activity = @page.activity_feed.activities.first
    expect(activity.text).to eq "#{current_user.name} changed the thing less than a minute ago"
  end
end
