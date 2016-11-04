require 'rails_helper'

RSpec.feature 'Resource manager manages holidays' do
  let(:users) do
    [
      create(:guider, name: 'First Guider'),
      create(:guider, name: 'Second Guider')
    ]
  end

  let(:today) { Time.zone.parse('2016-10-18 09:00') }
  let(:next_week) { BusinessDays.from_now(5).change(hour: 9, min: 0) }

  scenario 'Views holidays', js: true do
    given_the_user_is_a_resource_manager do
      travel_to today do
        and_there_are_some_holidays
        when_they_view_holidays
        then_they_can_see_the_holidays_for_this_week
        and_they_can_see_the_holidays_for_next_week
      end
    end
  end

  scenario 'Creates a holiday', js: true do
    given_the_user_is_a_resource_manager do
      travel_to today do
        and_there_is_a_guider
        when_they_view_holidays
        and_they_create_a_holiday
        then_they_can_see_the_holiday
      end
    end
  end

  scenario 'Deletes a holiday', js: true do
    given_the_user_is_a_resource_manager do
      travel_to today do
        and_there_are_guiders_with_holidays
        when_they_view_holidays
        when_they_delete_a_holiday
        then_it_is_deleted
      end
    end
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def and_there_are_some_holidays
    create(
      :holiday,
      user: users.first,
      title: 'First user holiday',
      start_at: today,
      end_at: today + 2.hours
    )
    create(
      :holiday,
      user: users.second,
      title: 'Second user holiday',
      start_at: next_week,
      end_at: next_week + 5.hours
    )
    users.each do |user|
      create(
        :holiday,
        user: user,
        title: 'Merged Holiday',
        start_at: today + 4.hours,
        end_at: today + 5.hours
      )
    end
    create(
      :bank_holiday,
      title: 'Christmas',
      start_at: next_week,
      end_at: next_week.end_of_day
    )
  end

  def and_there_is_a_holiday
    @holiday = create(
      :holiday,
      user: create(:guider),
      title: 'Some Holiday',
      start_at: today,
      end_at: today + 2.hours
    )
  end

  def when_they_view_holidays
    @page = Pages::Holidays.new.tap(&:load)
  end

  def then_they_can_see_the_holidays_for_this_week
    expect(@page.all_events).to eq [
      {
        title: 'First user holiday - First Guider',
        time: '9:00 - 11:00'
      },
      {
        title: 'Merged Holiday - First Guider, Second Guider',
        time: '13:00 - 14:00'
      }
    ]
  end

  def and_they_can_see_the_holidays_for_next_week
    @page.next_week.click
    expect(@page.all_events).to eq [
      {
        title: 'Christmas',
        time: '9:00 - 23:59'
      },
      {
        title: 'Second user holiday - Second Guider',
        time: '9:00 - 14:00'
      }
    ]
  end

  def and_there_is_a_guider
    @guider = create(:guider)
  end

  def and_they_create_a_holiday
    @page.wait_until_create_holiday_visible

    @page.create_holiday.click
    @page = Pages::NewHoliday.new

    @page.title.set 'Holiday Title'
    start_at = I18n.l(Time.zone.now.beginning_of_day.change(hour: 14), format: :date_range_picker)
    end_at = I18n.l(Time.zone.now.beginning_of_day.change(hour: 16), format: :date_range_picker)
    @page.date_range.set "#{start_at} - #{end_at}"
    page.execute_script '$(".daterangepicker").hide();'
    @page.select_all_users

    @page.save.click
  end

  def then_they_can_see_the_holiday
    @page = Pages::Holidays.new
    expect(@page).to be_displayed
    expect(@page.all_events).to eq [
      {
        title: "Holiday Title - #{@guider.name}",
        time: '14:00 - 16:00'
      }
    ]
  end

  def and_there_are_guiders_with_holidays
    @guiders = create_list(:guider, 2)
    @guiders.each do |guider|
      create(:holiday, title: 'Shared Holiday', user: guider, start_at: today + 2.hours)
    end
  end

  def when_they_delete_a_holiday
    @page.events.first.content.click
    @page = Pages::EditHoliday.new
    expect(@page).to be_displayed
    @page.delete.click
  end

  def then_it_is_deleted
    expect(Holiday.all).to be_empty
  end
end
