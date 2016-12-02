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

  context 'Multiple day holidays' do
    scenario 'Creates a holiday', js: true do
      given_the_user_is_a_resource_manager do
        travel_to today do
          and_there_is_a_guider
          when_they_view_holidays
          and_they_create_a_multiple_day_holiday
          then_they_can_see_the_multiple_day_holiday
        end
      end
    end

    scenario 'Updates a holiday', js: true do
      given_the_user_is_a_resource_manager do
        travel_to today do
          and_there_are_guiders_with_multiple_day_holidays
          when_they_view_holidays
          and_they_edit_the_multiple_day_holiday
          then_they_can_see_the_updated_multiple_day_holiday
        end
      end
    end
  end

  context 'Single day holidays' do
    scenario 'Creates a holiday', js: true do
      given_the_user_is_a_resource_manager do
        travel_to today do
          and_there_is_a_guider
          when_they_view_holidays
          and_they_create_a_single_day_holiday
          then_they_can_see_the_single_day_holiday
        end
      end
    end

    scenario 'Updates a holiday', js: true do
      given_the_user_is_a_resource_manager do
        travel_to today do
          and_there_are_guiders_with_single_day_holidays
          when_they_view_holidays
          and_they_edit_the_single_day_holiday
          then_they_can_see_the_updated_single_day_holiday
        end
      end
    end
  end

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

  scenario 'Deletes a holiday', js: true do
    given_the_user_is_a_resource_manager do
      travel_to today do
        and_there_are_guiders_with_multiple_day_holidays
        when_they_view_holidays
        when_they_delete_a_holiday
        then_it_is_deleted
      end
    end
  end

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
      all_day: true,
      start_at: next_week,
      end_at: next_week + 2.days
    )
  end

  def when_they_view_holidays
    @page = Pages::Holidays.new.tap(&:load)
  end

  def then_they_can_see_the_holidays_for_this_week
    expect_holidays_to_match(
      [
        {
          title: 'First user holiday',
          start_at: '2016-10-18T09:00:00.000Z',
          end_at: '2016-10-18T11:00:00.000Z'
        },
        {
          title: 'Merged Holiday',
          start_at: '2016-10-18T13:00:00.000Z',
          end_at: '2016-10-18T14:00:00.000Z'
        }
      ]
    )
  end

  def and_they_can_see_the_holidays_for_next_week
    @page.next_week.click
    expect_holidays_to_match(
      [
        {
          title: 'Second user holiday',
          start_at: '2016-10-25T09:00:00.000Z',
          end_at: '2016-10-25T14:00:00.000Z'

        },
        {
          title: 'Christmas',
          start_at: '2016-10-25',
          end_at: '2016-10-27'
        }
      ]
    )
  end

  def and_there_is_a_guider
    @guider = create(:guider)
  end

  def and_they_create_a_multiple_day_holiday
    @page.wait_until_create_holiday_visible

    @page.create_holiday.click
    @page = Pages::NewHoliday.new

    @page.title.set 'Holiday Title'
    @page.select_all_users
    @page.multi_day.set(true)
    @page.multiple_day.set_date_range(
      Time.zone.now.to_date,
      Time.zone.now.to_date + 2.days
    )

    @page.save.click
  end

  def and_they_create_a_single_day_holiday
    @page.wait_until_create_holiday_visible

    @page.create_holiday.click
    @page = Pages::NewHoliday.new

    @page.title.set 'Holiday Title'
    @page.select_all_users
    @page.multi_day.set(false)
    @page.single_day.set_date_range(
      Time.zone.now.beginning_of_day.change(hour: 14),
      Time.zone.now.beginning_of_day.change(hour: 16)
    )

    @page.save.click
  end

  def then_they_can_see_the_single_day_holiday
    @page = Pages::Holidays.new
    expect(@page).to be_displayed

    expect_holidays_to_match(
      title:    'Holiday Title',
      start_at: '2016-10-18T14:00:00.000Z',
      end_at:   '2016-10-18T16:00:00.000Z'
    )
  end

  def then_they_can_see_the_multiple_day_holiday
    @page = Pages::Holidays.new
    expect(@page).to be_displayed

    expect_holidays_to_match(
      title:    'Holiday Title',
      start_at: '2016-10-18',
      end_at:   '2016-10-20'
    )
  end

  def and_there_are_guiders_with_multiple_day_holidays
    @guiders = [
      create(:guider, name: 'a'),
      create(:guider, name: 'b')
    ]
    @guiders.each do |guider|
      create(
        :holiday,
        title: 'Shared All Day Holiday',
        all_day: true,
        user: guider,
        start_at: today + 2.hours,
        end_at: today + 1.day
      )
    end
  end

  def and_there_are_guiders_with_single_day_holidays
    @guiders = [
      create(:guider, name: 'a'),
      create(:guider, name: 'b')
    ]
    @guiders.each do |guider|
      create(
        :holiday,
        title: 'Shared Holiday',
        user: guider,
        start_at: today + 2.hours,
        end_at: today + 1.day
      )
    end
  end

  def and_they_edit_the_multiple_day_holiday
    @page.events.first.content.click
    @page = Pages::EditHoliday.new
    expect(@page).to be_displayed
    @page.title.set 'Some other holiday title'
    @page.select_user(@guiders.first)
    @page.multiple_day.set_date_range(
      Time.zone.now.to_date,
      Time.zone.now.to_date + 2.days
    )
    @page.save.click
  end

  def and_they_edit_the_single_day_holiday
    @page.events.first.content.click
    @page = Pages::EditHoliday.new
    expect(@page).to be_displayed
    @page.title.set 'Some other holiday title'
    @page.select_user(@guiders.first)
    @page.single_day.set_date_range(
      Time.zone.now.beginning_of_day.change(hour: 12),
      Time.zone.now.beginning_of_day.change(hour: 18)
    )
    @page.save.click
  end

  def then_they_can_see_the_updated_multiple_day_holiday
    @page = Pages::Holidays.new
    expect(@page).to be_displayed
    expect_holidays_to_match(
      title:    'Some other holiday title',
      start_at: '2016-10-18',
      end_at:   '2016-10-20'
    )
  end

  def then_they_can_see_the_updated_single_day_holiday
    @page = Pages::Holidays.new
    expect(@page).to be_displayed
    expect_holidays_to_match(
      title:    'Some other holiday title',
      start_at: '2016-10-18T12:00:00.000Z',
      end_at:   '2016-10-18T18:00:00.000Z'
    )
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

  def expect_holidays_to_match(expected_holidays)
    expected_holidays = [expected_holidays] if expected_holidays.is_a?(Hash)
    holidays = @page.calendar.holidays

    expect(holidays.count).to eq expected_holidays.count

    holidays.each_with_index do |holiday, index|
      expect(holiday[:title]).to eq expected_holidays[index][:title]
      expect(holiday[:start]).to eq expected_holidays[index][:start_at]
      expect(holiday[:end]).to eq expected_holidays[index][:end_at]
    end
  end
end
