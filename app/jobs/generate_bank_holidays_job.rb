class GenerateBankHolidaysJob < ApplicationJob
  queue_as :default

  def perform
    retrieve_holidays.each do |holiday|
      date = Date.parse(holiday[:date])
      logger.info "Adding holiday '#{holiday[:title]}' on '#{date}'"
      create_bank_holiday(
        holiday[:title],
        date.beginning_of_day,
        date.end_of_day
      )
    end
  end

  private

  def create_bank_holiday(title, start_at, end_at)
    Holiday.find_or_create_by!(
      title: title,
      start_at: start_at,
      end_at: end_at,
      all_day: true,
      bank_holiday: true
    )
  end

  def retrieve_holidays
    require 'open-uri'
    response = open('https://www.gov.uk/bank-holidays.json').read
    holidays = JSON.parse(response).with_indifferent_access
    holidays['england-and-wales'][:events]
  end
end
