require 'rails_helper'

RSpec.feature 'roles' do
  def when_they_try_to_manager_guiders
    @page = Pages::Users.new
    @page.load
  end

  def when_they_try_to_manage_guiders_slots
    @page = Pages::EditSlotRange.new
    @page.load(user_id: @guider.id, id: @slot_range.id)
  end

  def and_a_guider_with_a_slot_range_exists
    @guider = create(:guider_user)
    @slot_range = @guider.slot_ranges.create!(
      from: Time.zone.now
    )
    @slot_range.slots.create(
      day: 'Monday',
      start_at: '09:00',
      end_at: '10:30'
    )
  end

  def and_a_guider_exists
    @guider = create(:guider_user)
  end

  def then_they_can_manage_guiders_slots
    @page = Pages::EditSlotRange.new
    @page.load(user_id: @guider.id, id: @slot_range.id)
    expect(@page).to be_displayed
  end

  def when_they_try_to_edit_guiders_slot_ranges
    @page = Pages::EditUser.new
    @page.load(id: @guider.id)
  end

  def then_they_are_locked_out
    expect(@page).to have_permission_error_message
  end

  def then_they_are_allowed
    expect(@page).to_not have_permission_error_message
  end

  scenario 'does not allow non-resource-managers to manage guiders' do
    given_the_user_has_no_permissions do
      when_they_try_to_manager_guiders
      then_they_are_locked_out
    end
  end

  scenario 'allows resource managers to manage guiders' do
    given_the_user_is_a_resource_manager do
      when_they_try_to_manager_guiders
      then_they_are_allowed
    end
  end

  scenario 'does not allow non-resource-managers to manage guiders slot ranges' do
    given_the_user_has_no_permissions do
      and_a_guider_exists
      when_they_try_to_edit_guiders_slot_ranges
      then_they_are_locked_out
    end
  end

  scenario 'allows resource-managers to manage guiders slot ranges' do
    given_the_user_is_a_resource_manager do
      and_a_guider_exists
      when_they_try_to_edit_guiders_slot_ranges
      then_they_are_allowed
    end
  end

  scenario 'does not allow non-resource-managers to manage guiders slots' do
    given_the_user_has_no_permissions do
      and_a_guider_with_a_slot_range_exists
      when_they_try_to_manage_guiders_slots
      then_they_are_locked_out
    end
  end

  scenario 'allows resource-managers to manage guiders slots' do
    given_the_user_is_a_resource_manager do
      and_a_guider_with_a_slot_range_exists
      when_they_try_to_manage_guiders_slots
      then_they_are_allowed
    end
  end
end
