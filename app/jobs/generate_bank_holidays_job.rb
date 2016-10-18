class GenerateBankHolidaysJob < ApplicationJob
  queue_as :default

  def perform
    require 'open-uri'
    response = open('https://www.gov.uk/bank-holidays.json').read
    holidays = JSON.parse(response).with_indifferent_access
    events = holidays['england-and-wales'][:events]
    events.each do |event|
      date = Date.parse(event[:date])
      logger.info "Adding holiday '#{event[:title]}' on '#{date}'"
      Holiday.find_or_create_by!(
        title: event[:title],
        start_at: date.beginning_of_day,
        end_at: date.end_of_day
      )
    end
  end
end
