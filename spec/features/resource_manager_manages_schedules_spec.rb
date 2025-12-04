require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Resource manager manages schedules' do
  before do
    allow(GenerateBookableSlotsForUserJob).to receive(:perform_later)
  end

  scenario 'Non TPAS resource manager can see Saturday', js: true do
    given_the_user_is_a_resource_manager(organisation: :waltham_forest) do
      and_there_is_a_guider_for_waltham_forest
      when_they_edit_their_schedule
      then_they_see_the_weekend_columns
    end
  end

  scenario 'TPAS resource manager adds a due diligence schedule', js: true do
    allow(GenerateBookableSlotsForUserJob).to receive(:perform_later).and_call_original

    given_the_user_is_a_resource_manager(organisation: :tpas) do
      and_there_is_a_tpas_dummy_guider_schedule
      and_they_add_a_new_schedule
      and_they_set_the_initial_start_at_date
      and_they_add_some_time_slots
      then_they_do_not_see_weekend_columns
      when_they_save_the_users_time_slots
      then_they_are_told_that_the_schedule_has_been_created
      and_the_guider_has_those_time_slots_available
    end
  end

  scenario 'Successfully adds a new schedule', js: true do
    given_the_user_is_a_resource_manager do
      and_there_is_a_guider
      and_they_add_a_new_schedule
      and_they_set_the_initial_start_at_date
      and_they_add_some_time_slots
      when_they_save_the_users_time_slots
      then_they_are_told_that_the_schedule_has_been_created
      and_the_guider_has_those_time_slots_available
      and_the_guider_bookable_slots_are_regenerated
    end
  end

  scenario 'Successfully updates a schedule', js: true do
    given_the_user_is_a_resource_manager do
      and_there_is_a_guider
      and_the_guider_has_a_schedule_that_can_be_modified
      and_they_edit_the_schedule
      and_they_change_the_start_at_date
      and_they_change_the_time_slots
      when_they_save_the_users_time_slots
      then_they_are_told_that_the_schedule_has_been_updated
      and_the_guider_has_the_changed_time_slots
      and_the_guider_bookable_slots_are_regenerated
    end
  end

  scenario 'Successfully deletes a schedule' do
    given_the_user_is_a_resource_manager do
      and_there_is_a_guider
      and_the_guider_has_a_schedule_that_can_be_modified
      and_they_delete_the_schedule
      then_they_are_told_that_the_schedule_has_been_deleted
      and_the_schedule_is_deleted
      and_the_guider_bookable_slots_are_regenerated
    end
  end

  scenario 'Fails to modify an old schedule' do
    given_the_user_is_a_resource_manager do
      and_there_is_a_guider
      and_the_guider_has_a_schedule_that_can_not_be_modified
      then_they_cant_edit_the_schedule
      and_they_cant_delete_the_schedule
      and_the_guider_bookable_slots_are_not_regenerated
    end
  end

  scenario 'Adds a mid shift schedule', js: true do
    given_the_user_is_a_resource_manager do
      and_there_is_a_guider
      and_they_add_a_new_schedule
      and_they_set_the_initial_start_at_date
      and_they_add_the_default_mid_shift_slots
      when_they_save_the_users_time_slots
      then_they_are_told_that_the_schedule_has_been_created
      and_the_guider_has_the_mid_shift_time_slots_available
      and_the_guider_bookable_slots_are_regenerated
    end
  end

  def and_there_is_a_guider
    @guider = create(:guider, name: 'Davey Daverson')
  end

  def and_there_is_a_guider_for_waltham_forest
    @guider = create(:guider, :waltham_forest, name: 'Davey Daverson')
  end

  def when_they_edit_their_schedule
    @schedule = @guider.schedules.create!(start_at: 7.weeks.from_now)

    @page = Pages::EditSchedule.new
    @page.load(user_id: @guider.id, id: @schedule.id)
  end

  def then_they_see_the_weekend_columns
    expect(@page).to have_saturday
  end

  def and_the_guider_has_a_schedule_that_can_be_modified
    @schedule = @guider.schedules.create!(
      start_at: 7.weeks.from_now
    )
  end

  def and_the_guider_has_a_schedule_that_can_not_be_modified
    @schedule = @guider.schedules.create!(start_at: 5.days.ago)
    @guider.schedules.create!(start_at: 3.days.ago)
  end

  def click_on_day_and_time(day, time)
    page.find('[data-module="guider-slot-picker-calendar"]')
    time = "#{time}:00"

    x, y = page.driver.evaluate_script <<-JS
      function() {
        var $calendar = $('[data-module="guider-slot-picker-calendar"]');
        var $header = $calendar.find(".fc-day-header:contains('#{day}')");
        var $row = $calendar.find('[data-time="#{time}"]');
        return [$header.offset().left + 10, $row.offset().top + 10];
      }();
    JS

    # find body and click 'relative' to there
    page.find('body').click(x: x.to_i, y: y.to_i)
  end

  def and_they_add_a_new_schedule
    @page = Pages::NewSchedule.new
    @page.load(user_id: @guider.id)
  end

  def and_they_set_the_initial_start_at_date
    expect(@page.start_at.value).to eq(Time.current.strftime('%-d %b %Y'))

    @page.start_at.set '30 Sep 2016'
  end

  def and_they_add_some_time_slots
    click_on_day_and_time 'Monday', '09:00'
    click_on_day_and_time 'Tuesday', '10:30'
    expect(@page).to have_events(count: 2)
  end

  def then_they_do_not_see_weekend_columns
    expect(@page).to have_no_saturday
  end

  def and_they_add_the_default_mid_shift_slots
    accept_confirm do
      @page.mid.click
    end
  end

  def and_the_guider_has_the_mid_shift_time_slots_available
    schedule = @guider.schedules.first

    expect(schedule.slots.count).to eq 25
  end

  def when_they_save_the_users_time_slots
    @page.save.click
  end

  def then_they_are_told_that_the_schedule_has_been_created
    @page = Pages::EditUser.new
    expect(@page).to be_displayed
    expect(@page).to have_flash_of_success(text: 'Schedule has been created')
  end

  def then_they_are_told_that_the_schedule_has_been_updated
    @page = Pages::EditUser.new
    expect(@page).to be_displayed
    expect(@page).to have_flash_of_success(text: 'Schedule has been updated')
  end

  def then_they_are_told_that_the_schedule_has_been_deleted
    @page = Pages::EditUser.new
    expect(@page).to be_displayed
    expect(@page).to have_flash_of_success(text: 'Schedule has been deleted')
  end

  def and_they_edit_the_schedule
    @page = Pages::EditSchedule.new
    @page.load(user_id: @guider.id, id: @schedule.id)
  end

  def and_they_change_the_start_at_date
    @page.start_at.set '23 Nov 2020'
  end

  def and_they_change_the_time_slots
    click_on_day_and_time 'Wednesday', '09:30'
    click_on_day_and_time 'Thursday', '10:30'

    expect(@page).to have_events(count: 2)
  end

  def and_the_guider_has_the_changed_time_slots
    first_slot = @schedule.slots.where(day_of_week: 3).first
    expect(first_slot).to have_attributes(
      day_of_week: 3,
      start_hour: 9,
      start_minute: 30,
      end_hour: 10,
      end_minute: 40
    )

    second_slot = @schedule.slots.where(day_of_week: 4).first
    expect(second_slot).to have_attributes(
      day_of_week: 4,
      start_hour: 10,
      start_minute: 30,
      end_hour: 11,
      end_minute: 40
    )
  end

  def and_the_guider_has_those_time_slots_available
    expect(@guider.schedules.count).to eq 1
    schedule = @guider.schedules.first

    expect(schedule.slots.count).to eq 2

    expect(schedule.slots.first).to have_attributes(
      day_of_week: 1,
      start_hour: 9,
      start_minute: 0,
      end_hour: 10,
      end_minute: 10
    )

    expect(schedule.slots.second).to have_attributes(
      day_of_week: 2,
      start_hour: 10,
      start_minute: 30,
      end_hour: 11,
      end_minute: 40
    )
  end

  def and_they_delete_the_schedule
    @page = Pages::EditUser.new
    @page.load(id: @guider.id)
    @page.schedules.first.delete.click
  end

  def and_the_schedule_is_deleted
    expect(@guider.reload.schedules).to be_empty
  end

  def then_they_cant_edit_the_schedule
    @page = Pages::EditUser.new
    @page.load(id: @guider.id)
    expect(@page.schedules.last).to have_no_edit
  end

  def and_they_cant_delete_the_schedule
    @page = Pages::EditUser.new
    @page.load(id: @guider.id)
    expect(@page.schedules.last.delete).to be_disabled
  end

  def and_there_is_a_tpas_dummy_guider_schedule
    @guider = create(:guider, :tpas, :due_diligence)
  end

  def and_the_guider_bookable_slots_are_regenerated
    expect(GenerateBookableSlotsForUserJob).to have_received(:perform_later).with(@guider)
  end

  def and_the_guider_bookable_slots_are_not_regenerated
    expect(GenerateBookableSlotsForUserJob).to_not have_received(:perform_later)
  end
end
# rubocop:enable Metrics/BlockLength
