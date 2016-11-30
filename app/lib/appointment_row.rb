class AppointmentRow
  ROW_INDICES = {
    guider: 7,
    date: 10,
    time: 13,
    duration: 14,
    cancellation_date_time: 21,
    notes: 29,
    opt_out_of_market_research: 30,
    status: 34,
    booking_reference: 40,
    first_name: 41,
    last_name: 42,
    email: 43,
    mobile: 54,
    phone: 55,
    memorable_word: 61
  }.freeze

  def initialize(row)
    @row = row
  end

  ROW_INDICES.each do |key, value|
    define_method(key) { row[value] }
  end

  def start_at
    Time.zone.parse(date.sub('00:00', time))
  end

  def end_at
    start_at + duration.to_i.minutes
  end

  def pension_wise_status # rubocop:disable Metrics/MethodLength
    return :cancelled_by_customer if cancellation_date_time.present?

    case status
    when 'Complete', 'Incomplete'
      status.downcase.to_sym
    when 'No Show'
      :no_show
    when 'Ineligible'
      :ineligible_age
    else
      :pending
    end
  end

  private

  attr_reader :row
end
