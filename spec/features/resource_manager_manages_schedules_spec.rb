# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength

require 'rails_helper'

RSpec.feature 'Resource manager manages schedules' do
  scenario 'Successfully adds a new schedule', js: true do
    given_the_user_is_a_resource_manager do
      and_there_is_a_guider
      and_they_add_a_new_schedule
      and_they_set_the_from_date
      and_they_add_some_time_slots
      when_they_save_the_users_time_slots
      then_they_are_told_that_the_schedule_has_been_created
      and_the_guider_has_those_time_slots_available
    end
  end

  scenario 'Successfully updates a schedule', js: true do
    given_the_user_is_a_resource_manager do
      and_there_is_a_guider_with_a_schedule
      and_they_edit_the_schedule
      and_they_change_the_from_date
      and_they_change_the_time_slots
      when_they_save_the_users_time_slots
      then_they_are_told_that_the_schedule_has_been_updated
      and_the_guider_has_the_changed_time_slots
    end
  end

  scenario 'Fails to create a schedule with invalid from date' do
    given_the_user_is_a_resource_manager do
      and_there_is_a_guider
      and_they_add_a_new_schedule
      and_they_enter_an_invalid_from_date
      when_they_save_the_users_time_slots
      then_they_are_shown_an_error
    end
  end

  scenario 'Fails to update a schedule with invalid from date' do
    given_the_user_is_a_resource_manager do
      and_there_is_a_guider_with_a_schedule
      and_they_edit_the_schedule
      and_they_enter_an_invalid_from_date
      when_they_save_the_users_time_slots
      then_they_are_shown_an_error
    end
  end

  def and_there_is_a_guider
    @guider = create(:guider, name: 'Davey Daverson')
  end

  def and_there_is_a_guider_with_a_schedule
    @guider = create(:guider, name: 'Davey Daverson')
    @schedule = @guider.schedules.create!(
      from: 7.weeks.from_now
    )
  end

  def click_on_day_and_time(day, time)
    page.find('[data-module="GuiderSlotPickerCalendar"]')
    time = "#{time}:00"
    x, y = page.driver.evaluate_script <<-JS
      function() {
        var $calendar = $('[data-module="GuiderSlotPickerCalendar"]');
        var $header = $calendar.find(".fc-day-header:contains('#{day}')");
        var $row = $calendar.find('[data-time="#{time}"]');
        return [$header.offset().left + 10, $row.offset().top + 10];
      }();
    JS
    page.driver.click(x, y)
  end

  def and_they_add_a_new_schedule
    @page = Pages::NewSchedule.new
    @page.load(user_id: @guider.id)
  end

  def and_they_set_the_from_date
    fill_in 'From', with: '2018-10-23 00:00:00 UTC'
  end

  def and_they_add_some_time_slots
    click_on_day_and_time 'Monday', '09:00'
    click_on_day_and_time 'Tuesday', '10:30'
  end

  def when_they_save_the_users_time_slots
    @page.save_button.click
  end

  def then_they_are_told_that_the_schedule_has_been_created
    @page = Pages::EditUser.new
    expect(@page).to have_flash_of_success
  end

  def then_they_are_told_that_the_schedule_has_been_updated
    @page = Pages::EditUser.new
    expect(@page).to have_flash_of_success
  end

  def and_they_edit_the_schedule
    @page = Pages::EditSchedule.new
    @page.load(user_id: @guider.id, id: @schedule.id)
  end

  def and_they_change_the_from_date
    @page.from.set '2020-11-23 00:00:00 UTC'
  end

  def and_they_change_the_time_slots
    click_on_day_and_time 'Wednesday', '11:00'
    click_on_day_and_time 'Thursday', '10:30'
  end

  def and_the_guider_has_the_changed_time_slots
    @schedule.reload

    first_slot = @schedule.slots.first
    expect(first_slot.day).to eq 'Wednesday'
    expect(first_slot.start_at).to eq '11:00'
    expect(first_slot.end_at).to eq '12:10'

    second_slot = @schedule.slots.second
    expect(second_slot.day).to eq 'Thursday'
    expect(second_slot.start_at).to eq '10:30'
    expect(second_slot.end_at).to eq '11:40'
  end

  def and_the_guider_has_those_time_slots_available
    expect(@guider.schedules.count).to eq 1
    schedule = @guider.schedules.first

    expect(schedule.slots.count).to eq 2

    first_slot = schedule.slots.first
    expect(first_slot.day).to eq 'Monday'
    expect(first_slot.start_at).to eq '09:00'
    expect(first_slot.end_at).to eq '10:10'

    second_slot = schedule.slots.second
    expect(second_slot.day).to eq 'Tuesday'
    expect(second_slot.start_at).to eq '10:30'
    expect(second_slot.end_at).to eq '11:40'
  end

  def and_they_enter_an_invalid_from_date
    @page.from.set '2010-10-23 00:00:00 UTC'
  end

  def then_they_are_shown_an_error
    expect(@page).to have_error_summary
    expect(@page).to have_errors
  end
end
