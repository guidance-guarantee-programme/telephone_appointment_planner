require 'rails_helper'

RSpec.feature 'Roles' do
  context 'Team Leaders' do
    scenario 'Can run reports' do
      given_the_user_is_a_contact_centre_team_leader do
        when_they_try_to_view_appointment_reports
        then_they_are_allowed

        when_they_try_to_view_utilisation_reports
        then_they_are_allowed
      end
    end
  end

  context 'Resource Managers' do
    scenario 'Can manage guiders' do
      given_the_user_is_a_resource_manager do
        when_they_try_to_manage_guiders
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

    scenario 'Can manage holidays' do
      given_the_user_is_a_resource_manager do
        when_they_try_to_manage_holidays
        then_they_are_allowed
      end
    end

    scenario 'Can sort guiders' do
      given_the_user_is_a_resource_manager do
        when_they_try_to_sort_guiders
        then_they_are_allowed
      end
    end
  end

  context 'Guiders' do
    scenario 'Can view company calendar' do
      given_the_user_is_a_guider do
        when_they_try_to_view_the_company_calendar
        then_they_are_allowed
      end
    end

    scenario 'Can view their activities' do
      given_the_user_is_a_guider do
        when_they_try_to_view_their_activities
        then_they_are_allowed
      end
    end
  end

  context 'Users who are not Resource Managers, Agents, or Guiders' do
    scenario 'Can book appointments' do
      given_the_user_has_no_permissions do
        when_they_try_to_book_an_appointment
        then_they_are_allowed
      end
    end

    scenario 'Can reschedule appointments' do
      given_the_user_has_no_permissions do
        when_they_try_to_reschedule_an_appoinment
        then_they_are_allowed
      end
    end

    scenario 'Can not manage guiders' do
      given_the_user_has_no_permissions do
        when_they_try_to_manage_guiders
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

    scenario 'Can not manage holidays' do
      given_the_user_has_no_permissions do
        when_they_try_to_manage_holidays
        then_they_are_locked_out
      end
    end

    scenario 'Can not view the company calendar' do
      given_the_user_has_no_permissions do
        when_they_try_to_view_the_company_calendar
        then_they_are_locked_out
      end
    end

    scenario 'Can not view appointment reports' do
      given_the_user_has_no_permissions do
        when_they_try_to_view_appointment_reports
        then_they_are_locked_out
      end
    end

    scenario 'Can not view utilisation reports' do
      given_the_user_has_no_permissions do
        when_they_try_to_view_utilisation_reports
        then_they_are_locked_out
      end
    end

    scenario 'Can not sort guiders' do
      given_the_user_has_no_permissions do
        when_they_try_to_sort_guiders
        then_they_are_locked_out
      end
    end
  end

  def when_they_try_to_view_appointment_reports
    @page = Pages::NewAppointmentReport.new.tap(&:load)
  end

  def when_they_try_to_view_utilisation_reports
    @page = Pages::NewUtilisationReport.new.tap(&:load)
  end

  def when_they_try_to_manage_guiders
    @page = Pages::ManageGuiders.new.tap(&:load)
  end

  def when_they_try_to_manage_guiders_slots
    @page = Pages::EditSchedule.new
    @page.load(user_id: @guider.id, id: @schedule.id)
  end

  def when_they_try_to_manage_holidays
    @page = Pages::Holidays.new
    @page.load
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

  def when_they_try_to_book_an_appointment
    @page = Pages::NewAppointment.new
    @page.load
  end

  def when_they_try_to_reschedule_an_appoinment
    appointment = create(:appointment)
    @page = Pages::RescheduleAppointment.new
    @page.load(id: appointment.id)
  end

  def when_they_try_to_view_the_company_calendar
    @page = Pages::CompanyCalendar.new.tap(&:load)
  end

  def when_they_try_to_view_their_activities
    @page = Pages::Activities.new.tap(&:load)
  end

  def when_they_try_to_sort_guiders
    @page = Pages::SortGuiders.new.tap(&:load)
  end
end
