require 'rails_helper'

RSpec.feature 'Appointment audit trail' do
  scenario 'An agent changes an appointment and reviews the changes' do
    given_the_user_is_an_agent do
      and_there_is_an_appointment
      when_they_change_the_appointment
      then_change_can_be_seen_in_an_audit_activity
      and_when_they_click_the_audit_activity
      then_they_are_on_the_changes_page
      and_they_can_see_the_change_details
    end
  end

  def and_there_is_an_appointment
    @old_name = 'Jerry'
    @appointment = create(:appointment, first_name: @old_name)
  end

  def when_they_change_the_appointment
    @new_name = 'George'
    @edit_page = Pages::EditAppointment.new
    @edit_page.load(id: @appointment.id)
    @edit_page.first_name.set @new_name
    @edit_page.status.select('Incomplete')
    @edit_page.submit.click
  end

  def then_change_can_be_seen_in_an_audit_activity
    expect(@edit_page.activity_feed.audit_activity)
      .to have_text("#{GDS::SSO.test_user.name} changed the first name")
  end

  def and_when_they_click_the_audit_activity
    @edit_page.activity_feed.more_activity_link.click
  end

  def then_they_are_on_the_changes_page
    @changes_page = Pages::AppointmentChanges.new
    @changes_page.displayed?
  end

  def and_they_can_see_the_change_details
    expect(@changes_page.changes_table.change_rows.first).to have_text('First name')
    expect(@changes_page.changes_table.change_rows.first).to have_text(@old_name)
    expect(@changes_page.changes_table.change_rows.first).to have_text(@new_name)

    expect(@changes_page.changes_table.change_rows.last).to have_text('Status')
    expect(@changes_page.changes_table.change_rows.last).to have_text('Pending')
    expect(@changes_page.changes_table.change_rows.last).to have_text('Incomplete')
  end
end
