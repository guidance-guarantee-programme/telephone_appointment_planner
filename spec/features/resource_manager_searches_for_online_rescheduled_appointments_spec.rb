require 'rails_helper'

RSpec.feature 'Resource manager searches online rescheduled appointments' do # rubocop:disable Metrics/BlockLength
  scenario 'Viewing appointments that were rescheduled away from my organisation' do
    given_the_user_is_a_resource_manager(organisation: :tpas) do
      travel_to '2025-01-30 13:00' do
        and_there_are_appointments_that_were_rescheduled_away
        when_they_view_the_rescheduled_appointments
        they_see_the_rescheduled_appointments
      end
    end
  end

  def and_there_are_appointments_that_were_rescheduled_away
    @guider = create(:guider, :waltham_forest)

    @first = create(
      :appointment,
      start_at: Time.zone.parse('2025-02-02 13:00'),
      rescheduled_at: Time.zone.parse('2025-02-01 12:00'),
      previous_guider: create(:guider, :tpas),
      guider: @guider
    )

    @second = create(
      :appointment,
      start_at: Time.zone.parse('2025-02-02 14:00'),
      rescheduled_at: Time.zone.parse('2025-02-01 13:00'),
      previous_guider: create(:guider, :tpas),
      guider: @guider
    )
  end

  def when_they_view_the_rescheduled_appointments
    @page = Pages::OnlineReschedulingsSearch.new
    @page.load
  end

  def they_see_the_rescheduled_appointments
    expect(@page).to have_results(count: 2)

    @page.results.first.tap do |result|
      expect(result.id).to have_text(@first.id)
      expect(result.customer_name).to have_text(@first.name)
      expect(result.previous_guider_name).to have_text(@first.previous_guider.name)
      expect(result.appointment_date_time).to have_text('02 February 2025 13:00')
      expect(result.rescheduled_date_time).to have_text('01 February 2025 12:00')
    end
  end
end
