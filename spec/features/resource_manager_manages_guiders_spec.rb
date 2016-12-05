require 'rails_helper'

RSpec.feature 'Resource manager manages guiders' do
  scenario 'Viewing and filtering by groups', js: true do
    given_the_user_is_a_resource_manager do
      and_there_are_guiders_assigned_to_groups
      when_they_visit_the_guiders_page
      then_they_see_all_the_guiders
      when_they_filter_by_a_specific_group
      then_they_see_only_those_guiders
    end
  end

  scenario 'Assigning a new group to multiple guiders', js: true do
    given_the_user_is_a_resource_manager do
      and_there_are_guiders_assigned_to_groups
      when_they_visit_the_guiders_page
      and_they_choose_to_add_groups_to_multiple_guiders
      then_they_see_the_guiders_they_will_affect
      when_they_create_a_new_group
      then_the_group_is_assigned_to_those_guiders
    end
  end

  scenario 'Unassigning a group from multiple guiders', js: true do
    given_the_user_is_a_resource_manager do
      and_there_are_guiders_assigned_to_groups
      when_they_visit_the_guiders_page
      and_they_choose_to_remove_groups_from_multiple_guiders
      then_they_see_the_guiders_they_will_affect
      when_they_remove_a_group
      then_the_group_is_unassigned_from_those_guiders
    end
  end

  scenario 'Deactivating a guider' do
    given_the_user_is_a_resource_manager do
      and_there_is_a_guider_with_bookable_slots
      when_they_deactivate_the_guider
      then_the_guider_is_not_active
      and_they_have_no_bookable_slots
    end
  end

  scenario 'Activating a deactivated guider' do
    given_the_user_is_a_resource_manager do
      and_there_is_a_deactivated_guider_with_bookable_slots
      when_they_activate_the_guider
      then_the_guider_is_active
      and_they_have_bookable_slots
    end
  end

  def and_they_choose_to_remove_groups_from_multiple_guiders
    and_they_choose_to_add_groups_to_multiple_guiders
  end

  def when_they_remove_a_group
    @page.groups.first.remove.click
  end

  def then_the_group_is_unassigned_from_those_guiders
    expect(@page).to have_flash_of_success
    expect(@page).to have_no_text(@team_one.name)
  end

  def and_they_choose_to_add_groups_to_multiple_guiders
    @page.guiders.map(&:checkbox).each { |c| c.set(true) }
    @page.wait_until_action_panel_visible

    @page.action_panel.go.click
  end

  def then_they_see_the_guiders_they_will_affect
    @page = Pages::ManageGroups.new
    expect(@page).to be_displayed

    expect(@page.affected).to have_text(@guider.name)
    expect(@page.affected).to have_text(@other.name)
  end

  def when_they_create_a_new_group
    @page.group.set 'Trainees'
    @page.add_group.click
  end

  def then_the_group_is_assigned_to_those_guiders
    expect(@page).to have_flash_of_success
    expect(@page).to have_text('Trainees')
  end

  def and_there_are_guiders_assigned_to_groups
    @team_one = create(:group)
    @team_two = create(:group)
    @guider   = create(:guider) { |g| g.groups << @team_one }
    @other    = create(:guider) { |g| g.groups << @team_two }
  end

  def when_they_visit_the_guiders_page
    @page = Pages::ManageGuiders.new.tap(&:load)
  end

  def then_they_see_all_the_guiders
    expect(@page).to have_guiders(count: 2)
  end

  def when_they_filter_by_a_specific_group
    @page.search.set @team_one.name
  end

  def then_they_see_only_those_guiders
    # this will wait for the JS search to complete
    expect(@page).to have_text(@guider.name)
    expect(@page).to have_guiders(count: 1)

    @page.guiders.first.tap do |guider|
      expect(guider).to have_groups(count: 1)
      expect(guider.groups.first).to have_text(@team_one.name)
    end
  end

  def and_there_is_a_guider_with_bookable_slots
    @guider = create(:guider)

    day = BusinessDays.from_now(5)
    @guider.schedules.create(
      start_at: day.beginning_of_day,
      slots: [
        build(:nine_thirty_slot, day_of_week: day.wday),
        build(:four_fifteen_slot, day_of_week: day.wday)
      ]
    )

    BookableSlot.generate_for_six_weeks
  end

  def when_they_deactivate_the_guider
    @page = Pages::ManageGuiders.new.tap(&:load)
    @page.deactivate.click
  end

  def then_the_guider_is_not_active
    expect(@page).to have_flash_of_success
    expect(@page.guiders.first).to_not have_active_icon
    expect(@guider.reload.active).to be false
  end

  def and_they_have_no_bookable_slots
    expect(@guider.bookable_slots).to be_empty
  end

  def and_there_is_a_deactivated_guider_with_bookable_slots
    @guider = create(:guider, active: false)

    day = BusinessDays.from_now(5)
    @guider.schedules.create(
      start_at: day.beginning_of_day,
      slots: [
        build(:nine_thirty_slot, day_of_week: day.wday),
        build(:four_fifteen_slot, day_of_week: day.wday)
      ]
    )

    BookableSlot.generate_for_six_weeks
  end

  def when_they_activate_the_guider
    @page = Pages::ManageGuiders.new.tap(&:load)
    @page.activate.click
  end

  def then_the_guider_is_active
    expect(@page).to have_flash_of_success
    expect(@page.guiders.first).to have_active_icon
    expect(@guider.reload.active).to be true
  end

  def and_they_have_bookable_slots
    expect(@guider.bookable_slots).to_not be_empty
  end
end
