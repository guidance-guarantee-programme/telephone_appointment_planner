require 'rails_helper'

RSpec.feature 'Roles' do
  context 'Resource Managers' do
    scenario 'Can manage guiders' do
      given_the_user_is_a_resource_manager do
        when_they_try_to_manager_guiders
        then_they_are_allowed
      end
    end

    scenario 'Can manage guiders schedules' do
      given_the_user_is_a_resource_manager do
        and_a_guider_exists
        when_they_try_to_edit_guiders_schedules
        then_they_are_allowed
      end
    end

    scenario 'Can manage guiders slots' do
      given_the_user_is_a_resource_manager do
        and_a_guider_with_a_schedule_exists
        when_they_try_to_manage_guiders_slots
        then_they_are_allowed
      end
    end
  end

  context 'Agents' do
    scenario 'Can attempt appointments' do
      given_the_user_is_an_agent do
        when_they_try_to_attempt_an_appointment
        then_they_are_allowed
      end
    end

    scenario 'Can book appointments' do
      given_the_user_is_an_agent do
        when_they_try_to_book_an_appointment
        then_they_are_allowed
      end
    end
  end

  context 'Users who are not Agents' do
    scenario 'Can not attempt appointments' do
      given_the_user_has_no_permissions do
        when_they_try_to_attempt_an_appointment
        then_they_are_locked_out
      end
    end

    scenario 'Can not book appointments' do
      given_the_user_has_no_permissions do
        when_they_try_to_book_an_appointment
        then_they_are_locked_out
      end
    end
  end

  context 'Users who are not Resource Managers' do
    scenario 'Can not manage guiders' do
      given_the_user_has_no_permissions do
        when_they_try_to_manager_guiders
        then_they_are_locked_out
      end
    end

    scenario 'Can not manage guiders schedules' do
      given_the_user_has_no_permissions do
        and_a_guider_exists
        when_they_try_to_edit_guiders_schedules
        then_they_are_locked_out
      end
    end

    scenario 'Can not manage guiders slots' do
      given_the_user_has_no_permissions do
        and_a_guider_with_a_schedule_exists
        when_they_try_to_manage_guiders_slots
        then_they_are_locked_out
      end
    end
  end

  def when_they_try_to_manager_guiders
    @page = Pages::Users.new
    @page.load
  end

  def when_they_try_to_manage_guiders_slots
    @page = Pages::EditSchedule.new
    @page.load(user_id: @guider.id, id: @schedule.id)
  end

  def and_a_guider_with_a_schedule_exists
    @guider = create(:guider)
    @schedule = @guider.schedules.create!(
      start_at: 7.weeks.from_now
    )
  end

  def and_a_guider_exists
    @guider = create(:guider)
  end

  def then_they_can_manage_guiders_slots
    @page = Pages::EditSchedule.new
    @page.load(user_id: @guider.id, id: @schedule.id)
    expect(@page).to be_displayed
  end

  def when_they_try_to_edit_guiders_schedules
    @page = Pages::EditUser.new
    @page.load(id: @guider.id)
  end

  def then_they_are_locked_out
    expect(@page).to have_permission_error_message
  end

  def then_they_are_allowed
    expect(@page).to_not have_permission_error_message
  end

  def when_they_try_to_attempt_an_appointment
    @page = Pages::NewAppointmentAttempt.new
    @page.load
  end

  def when_they_try_to_book_an_appointment
    appointment_attempt = create(:appointment_attempt)
    @page = Pages::NewAppointment.new
    @page.load(appointment_attempt_id: appointment_attempt.id)
  end
end
