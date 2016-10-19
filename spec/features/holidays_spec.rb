require 'rails_helper'

RSpec.feature 'Holidays' do
  describe 'Viewing holidays' do
    let(:users) do
      [
        create(:guider, name: 'First Guider'),
        create(:guider, name: 'Second Guider')
      ]
    end

    let(:today) { BusinessDays.from_now(0).change(hour: 9, min: 0) }
    let(:next_week) { BusinessDays.from_now(6).change(hour: 9, min: 0) }

    scenario 'displays all holidays', js: true do
      given_the_user_is_a_resource_manager do
        and_there_are_some_holidays
        when_they_view_holidays
        then_they_can_see_the_holidays_for_this_week
        and_they_can_see_the_holidays_for_next_week
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
        :holiday,
        title: 'Christmas',
        start_at: next_week,
        end_at: next_week.end_of_day
      )
    end

    def when_they_view_holidays
      @page = Pages::Holidays.new.tap(&:load)
    end

    def then_they_can_see_the_holidays_for_this_week
      expect(@page.all_appointments).to eq [
        {
          title: 'First user holiday - First Guider',
          time: '9:00 - 11:00'
        },
        {
          title: 'Merged Holiday - First Guider, Second Guider',
          time: '1:00 - 2:00'
        }
      ]
    end

    def and_they_can_see_the_holidays_for_next_week
      @page.next_week.click
      expect(@page.all_appointments).to eq [
        {
          title: 'Christmas',
          time: '9:00 - 11:59'
        },
        {
          title: 'Second user holiday - Second Guider',
          time: '9:00 - 2:00'
        }
      ]
    end
  end
end
