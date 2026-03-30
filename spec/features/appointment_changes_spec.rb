require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Appointment audit trail' do
  scenario 'An agent changes an appointment and reviews the changes', js: true do
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
    @edit_page.first_name.native.clear # workaround weird chrome-driver bug
    @edit_page.first_name.set(@new_name)
    @edit_page.status.select('Cancelled By Customer')
    @edit_page.wait_until_secondary_status_options_visible
    @edit_page.secondary_status.select('Cancelled prior to appointment')
    @edit_page.wait_until_cancelled_via_phone_visible
    @edit_page.cancelled_via_phone.set(true)
    @edit_page.submit.click
  end

  def then_change_can_be_seen_in_an_audit_activity
    expect(@edit_page.activity_feed.audit_activity)
      .to have_text("#{GDS::SSO.test_user.name} changed the cancelled via, first name, secondary status, and status")
  end

  def and_when_they_click_the_audit_activity
    @edit_page.activity_feed.more_activity_link.click
  end

  def then_they_are_on_the_changes_page
    @changes_page = Pages::AppointmentChanges.new
    @changes_page.displayed?
  end

  def and_they_can_see_the_change_details
    rows = @changes_page.changes_table.change_rows.map(&:text).sort

    expect(rows).to eq(
      [
        'Cancelled via - Phone',
        'First name Jerry George',
        'Secondary status - Cancelled prior to appointment',
        'Status Pending Cancelled by customer'
      ]
    )
  end
end
# rubocop:enable Metrics/BlockLength
