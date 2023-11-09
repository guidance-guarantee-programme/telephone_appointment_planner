class Search
  include ActiveModel::Model
  include DateRangePickerHelper

  attr_accessor :q, :date_range, :current_user, :appointment_type
  attr_writer :processed

  def results # rubocop:disable Metrics/MethodLength
    range = date_range
            .to_s
            .split(' - ')
            .map { |d| strp_date_range_picker_date(d) }

    AppointmentSearch.new(
      q,
      range.first.try(:beginning_of_day),
      range.last.try(:end_of_day),
      current_user,
      processed,
      appointment_type
    ).search
  end

  def processed
    return '' if current_user.tpas?

    @processed || 'no'
  end
end
