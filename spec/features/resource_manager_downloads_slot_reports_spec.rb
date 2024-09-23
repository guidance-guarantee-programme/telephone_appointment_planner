require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Resource manager downloads slot reports' do
  scenario 'appointment with date at end of range is included' do
    given_the_user_is_a_resource_manager do
      travel_to '2024-09-17 13:00' do
        and_there_are_data
        when_they_download_the_report
        then_they_see_the_correct_results
      end
    end
  end

  let(:start_at) do
    BusinessDays.from_now(10).to_date
  end

  let(:created_at) do
    BusinessDays.from_now(20).to_date
  end

  def and_there_are_data
    @bookable_slot = create(
      :bookable_slot,
      start_at: BusinessDays.from_now(20),
      guider: create(:guider, name: 'Daisy George')
    )

    @other_slot = create(
      :bookable_slot,
      start_at: BusinessDays.from_now(20),
      guider: create(:guider, :cas, name: 'George Daisy')
    )
  end

  def when_they_download_the_report
    @page = Pages::NewBookableSlotReport.new.tap(&:load)
    @page.date_range.set date_range_enclosing(created_at)
    @page.download.click
  end

  def then_they_see_the_correct_results
    @page = Pages::ReportCsv.new

    expected_file_name = "slots-report-#{created_at.to_time.to_i}-#{created_at.to_time.to_i}.csv"
    expect_csv_content_disposition(expected_file_name)

    expect(@page.csv.count).to eq 2
    expect(@page.csv.first).to eq %i[created_at guider start_at end_at]

    expect(@page.csv.second).to match_array [
      @bookable_slot.created_at.to_s,
      @bookable_slot.start_at.to_s,
      @bookable_slot.end_at.to_s,
      @bookable_slot.guider.name
    ]
  end

  def date_range_enclosing(date)
    [
      I18n.l(date, format: :date_range_picker),
      I18n.l(date, format: :date_range_picker)
    ].join(' - ')
  end

  def expect_csv_content_disposition(file_name)
    expect(@page.content_disposition).to eq "attachment; filename=\"#{file_name}\""
  end
end
# rubocop:enable Metrics/BlockLength
