require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Resource manager downloads holiday reports' do
  scenario 'the correct CSV is generated' do
    given_the_user_is_a_resource_manager do
      travel_to '2024-09-17 13:00' do
        and_there_are_data
        when_they_download_the_report
        then_they_see_the_correct_results
      end
    end
  end

  def and_there_are_data
    @holiday = create(
      :holiday,
      start_at: Time.zone.parse('2024-09-18 09:00'),
      end_at: Time.zone.parse('2024-09-18 17:00')
    )
  end

  def when_they_download_the_report
    @page = Pages::NewHolidayReport.new.tap(&:load)
    @page.date_range.set '18/09/2024 - 18/09/2024'
    @page.download.click
  end

  def then_they_see_the_correct_results
    @page = Pages::ReportCsv.new
    expect(@page.content_disposition).to match(/attachment; filename="holidays-report-\d+-\d+.csv"/)

    expect(@page.csv.count).to eq 2
    expect(@page.csv.first).to eq %i[created_at title guider start_at end_at all_day]

    expect(@page.csv.second).to match_array [
      @holiday.created_at.to_s,
      @holiday.title,
      @holiday.user.name,
      @holiday.start_at.to_s,
      @holiday.end_at.to_s,
      'False'
    ]
  end

  def date_range_enclosing(date)
    [
      I18n.l(date, format: :date_range_picker),
      I18n.l(date, format: :date_range_picker)
    ].join(' - ')
  end
end
# rubocop:enable Metrics/BlockLength
