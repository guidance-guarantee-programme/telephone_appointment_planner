# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength

require 'rails_helper'

RSpec.feature 'slot ranges' do
  def and_there_is_a_guider
    @guider = create(:guider_user, name: 'Davey Daverson')
  end

  def and_there_is_a_guider_with_a_slot_range
    @guider = create(:guider_user, name: 'Davey Daverson')
    @slot_range = @guider.slot_ranges.create!(
      from: Time.zone.now
    )
  end

  def when_they_manage_guiders
    visit root_path
    click_link 'Manage guiders'
  end

  def then_they_see_the_guider_name_listed
    expect(page).to have_content @guider.name
  end

  def when_they_edit_the_guider
    click_link "Edit #{@guider.name}"
  end

  def then_they_cannot_manage_guiders
    visit root_path
    expect(page).to_not have_link 'Manage guiders'
  end

  def click_on_day_and_time(day, time)
    time = "#{time}:00"
    x, y = page.driver.evaluate_script <<-JS
      function() {
        var $calendar = $('[data-calendar]');
        var $header = $calendar.find(".fc-day-header:contains('#{day}')");
        var $row = $calendar.find('[data-time="#{time}"]');
        return [$header.offset().left + 10, $row.offset().top + 10];
      }();
    JS
    page.driver.click(x, y)
  end

  def ensure_calendar_exists
    page.find('[data-calendar]')
  end

  def and_they_add_a_new_slot_range
    click_link 'Add slot range'
  end

  def and_they_set_the_from_date
    fill_in 'From', with: '2018-10-23 00:00:00 UTC'
  end

  def and_they_add_some_time_slots
    ensure_calendar_exists
    click_on_day_and_time 'Monday', '09:00'
    click_on_day_and_time 'Tuesday', '10:30'
  end

  def when_they_save_the_users_time_slots
    click_button 'Save'
  end

  def then_they_are_told_that_the_slot_range_has_been_created
    @page = Pages::Layout.new
    expect(@page).to have_flash_of_success
  end

  def then_they_are_told_that_the_slot_range_has_been_updated
    @page = Pages::Layout.new
    expect(@page).to have_flash_of_success
  end

  def and_the_edit_the_slot_range
    click_link "Edit Slot Range #{@slot_range.display_title}"
  end

  def and_they_change_the_from_date
    fill_in 'From', with: '2020-11-23 00:00:00 UTC'
  end

  def and_they_change_the_time_slots
    click_on_day_and_time 'Wednesday', '11:00'
    click_on_day_and_time 'Thursday', '10:30'
  end

  def and_the_guider_has_the_changed_time_slots
    @slot_range.reload

    first_slot = @slot_range.slots.first
    expect(first_slot.day).to eq 'Wednesday'
    expect(first_slot.start_at).to eq '11:00'
    expect(first_slot.end_at).to eq '12:10'

    second_slot = @slot_range.slots.second
    expect(second_slot.day).to eq 'Thursday'
    expect(second_slot.start_at).to eq '10:30'
    expect(second_slot.end_at).to eq '11:40'
  end

  def and_the_guider_has_those_time_slots_available
    expect(@guider.slot_ranges.count).to eq 1
    slot_range = @guider.slot_ranges.first

    expect(slot_range.slots.count).to eq 2

    first_slot = slot_range.slots.first
    expect(first_slot.day).to eq 'Monday'
    expect(first_slot.start_at).to eq '09:00'
    expect(first_slot.end_at).to eq '10:10'

    second_slot = slot_range.slots.second
    expect(second_slot.day).to eq 'Tuesday'
    expect(second_slot.start_at).to eq '10:30'
    expect(second_slot.end_at).to eq '11:40'
  end

  scenario 'Successfully adding a new slot range to a guider', js: true do
    given_the_user_is_a_resource_manager do
      and_there_is_a_guider
      when_they_manage_guiders
      then_they_see_the_guider_name_listed
      when_they_edit_the_guider
      and_they_add_a_new_slot_range
      and_they_set_the_from_date
      and_they_add_some_time_slots
      when_they_save_the_users_time_slots
      then_they_are_told_that_the_slot_range_has_been_created
      and_the_guider_has_those_time_slots_available
    end
  end

  scenario 'Successfully update a slot range for a guider', js: true do
    given_the_user_is_a_resource_manager do
      and_there_is_a_guider_with_a_slot_range
      when_they_manage_guiders
      then_they_see_the_guider_name_listed
      when_they_edit_the_guider
      and_the_edit_the_slot_range
      and_they_change_the_from_date
      and_they_change_the_time_slots
      when_they_save_the_users_time_slots
      then_they_are_told_that_the_slot_range_has_been_updated
      and_the_guider_has_the_changed_time_slots
    end
  end

  scenario 'Users without resource_manager permission can\'t manage resources' do
    given_the_user_has_no_permissions do
      then_they_cannot_manage_guiders
    end
  end
end
