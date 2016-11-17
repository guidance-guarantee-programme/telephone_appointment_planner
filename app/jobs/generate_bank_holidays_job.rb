class GenerateBankHolidaysJob < ApplicationJob
  queue_as :default

  def perform
    retrieve_holidays.each do |holiday|
      date = Date.parse(holiday[:date])
      logger.info "Adding holiday '#{holiday[:title]}' on '#{date}'"
      Holiday.find_or_create_by!(
        title: holiday[:title],
        start_at: date.beginning_of_day,
        end_at: date.end_of_day,
        bank_holiday: true,
        all_day: true
      )
    end
  end

  private

  def retrieve_holidays
    require 'open-uri'
    response = open('https://www.gov.uk/bank-holidays.json').read
    holidays = JSON.parse(response).with_indifferent_access
    holidays['england-and-wales'][:events]
  end
end
